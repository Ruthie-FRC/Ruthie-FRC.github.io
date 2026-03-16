# Data Types

PowerShell is built on .NET, so every value has a .NET type. Understanding types helps you write correct, efficient scripts.

---

## Common Types at a Glance

| Type Accelerator | .NET Class | Literal / Example |
|-----------------|-----------|-------------------|
| `[string]` | `System.String` | `"hello"`, `'world'` |
| `[int]` | `System.Int32` | `42` |
| `[long]` | `System.Int64` | `1000000000` |
| `[double]` | `System.Double` | `3.14` |
| `[decimal]` | `System.Decimal` | `1.99D` |
| `[bool]` | `System.Boolean` | `$true`, `$false` |
| `[char]` | `System.Char` | `[char]'A'` |
| `[byte]` | `System.Byte` | `[byte]255` |
| `[datetime]` | `System.DateTime` | `Get-Date` |
| `[timespan]` | `System.TimeSpan` | `New-TimeSpan -Hours 1` |
| `[array]` | `System.Object[]` | `@(1,2,3)` |
| `[hashtable]` | `System.Collections.Hashtable` | `@{a=1}` |
| `[xml]` | `System.Xml.XmlDocument` | `[xml]'<root/>'` |
| `[regex]` | `System.Text.RegularExpressions.Regex` | `[regex]'\d+'` |
| `[scriptblock]` | `System.Management.Automation.ScriptBlock` | `{ Get-Date }` |
| `[type]` | `System.Type` | `[int]` |

---

## Strings

### Creation

```powershell
$s1 = "double-quoted"  # supports variable/expression expansion
$s2 = 'single-quoted'  # literal — no expansion
$s3 = @"
This is a
here-string. Variables like $env:USERNAME are expanded.
"@
$s4 = @'
Literal here-string. No expansion: $env:USERNAME stays as-is.
'@
```

### Useful string methods

```powershell
$s = "Hello, World!"

$s.Length                     # 13
$s.ToUpper()                  # "HELLO, WORLD!"
$s.ToLower()                  # "hello, world!"
$s.Replace("World", "PS")     # "Hello, PS!"
$s.Split(",")                 # @("Hello", " World!")
$s.Trim()                     # removes leading/trailing whitespace
$s.TrimStart("H")             # "ello, World!"
$s.StartsWith("Hello")        # $true
$s.EndsWith("!")              # $true
$s.Contains("World")          # $true
$s.IndexOf("World")           # 7
$s.Substring(7, 5)            # "World"
$s -replace "World", "PS"     # "Hello, PS!" (regex replace)
$s -like "*World*"            # $true (wildcard)
$s -match "W(\w+)"            # $true; $Matches[1] = "orld"
```

### Formatting strings

```powershell
"Pi is {0:F4}" -f [math]::PI          # "Pi is 3.1416"
"Count: {0:N0}" -f 1234567            # "Count: 1,234,567"
"{0,-10} | {1,10}" -f "Name", "Value" # left/right align
[string]::Format("{0} + {1} = {2}", 1, 2, 3)
```

---

## Numbers

```powershell
$i  = 42          # int
$l  = 9999999999L # long (suffix L)
$d  = 3.14        # double
$dc = 19.99D      # decimal (financial use)
$h  = 0xFF        # hex literal = 255
$b  = 0b1010      # binary literal = 10 (PS 6+)

# Arithmetic
10 / 3            # 3.33333... (double)
[int](10 / 3)     # 3 (truncated)
10 % 3            # 1 (modulo)
[math]::Pow(2,8)  # 256.0
[math]::Sqrt(16)  # 4.0
[math]::Round(3.14159, 2)  # 3.14

# Size suffixes (available since PS 1.0)
1KB   # 1024
1MB   # 1048576
1GB   # 1073741824
1TB   # 1099511627776
```

---

## Booleans

```powershell
$true
$false

# Truthiness rules
if (0)    { }  # falsy
if ("")   { }  # falsy
if ($null){ }  # falsy
if (@())  { }  # falsy (empty array)

if (1)           { "truthy" }
if ("text")      { "truthy" }
if (@(0))        { "truthy" }  # array with one element is truthy even if element is 0
if ($false -or $true) { "truthy" }
```

---

## DateTime and TimeSpan

```powershell
$now   = Get-Date
$epoch = [datetime]"2024-01-01"
$ts    = New-TimeSpan -Days 7

# Date math
$now.AddDays(30)
$now.AddHours(-6)
$now - $epoch        # returns a TimeSpan

# Formatting
$now.ToString("yyyy-MM-dd")
$now.ToString("ddd, dd MMM yyyy HH:mm:ss")

# TimeSpan properties
$ts.Days
$ts.TotalHours
$ts.TotalMinutes
```

---

## Arrays

```powershell
# Create
$a = @(1, 2, 3, 4, 5)
$a = 1..10            # range 1 to 10
$a = ,1               # single-element array

# Access
$a[0]                 # first element
$a[-1]                # last element
$a[1..3]              # slice: elements at index 1, 2, 3
$a[-3..-1]            # last 3 elements

# Properties and methods
$a.Count
$a.Length
$a.Contains(3)        # $true
[Array]::IndexOf($a, 3)  # 2

# Modify (arrays are fixed-size; += creates a new array)
$a += 6
$a = $a | Where-Object { $_ -ne 2 }  # remove element

# ArrayList for performance when adding/removing many items
$list = [System.Collections.Generic.List[int]]::new()
$list.Add(1); $list.Add(2); $list.Remove(1)
```

---

## Hash Tables

```powershell
$ht = @{ Key = "Value"; Count = 42 }

# Ordered hashtable (preserves insertion order)
$ht = [ordered]@{ First = 1; Second = 2; Third = 3 }

# Access
$ht.Key
$ht["Count"]
$ht.ContainsKey("Key")   # $true
$ht.ContainsValue(42)    # $true

# Enumerate
foreach ($key in $ht.Keys) {
    "$key = $($ht[$key])"
}
$ht.GetEnumerator() | Sort-Object Name
```

---

## Type Conversion

```powershell
[int]"42"            # string to int
[string]42           # int to string
[datetime]"2024-03-15"  # string to datetime
[double]"3.14"       # string to double
[bool]1              # $true
[bool]0              # $false
[char]65             # 'A'
[byte[]][char[]]"Hi" # string to byte array

# Safe conversion with -as
$val = "123abc"
$n = $val -as [int]  # $null if conversion fails (no exception)
```

---

## Type Testing

```powershell
$x = 42
$x -is [int]          # $true
$x -is [string]       # $false
$x -isnot [string]    # $true
$x.GetType()          # System.Int32
$x.GetType().Name     # "Int32"
$x.GetType().FullName # "System.Int32"
```
