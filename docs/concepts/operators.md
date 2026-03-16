# Operators

PowerShell provides a rich set of operators for comparison, arithmetic, logical operations, string manipulation, and more.

---

## Arithmetic Operators

| Operator | Description | Example | Result |
|----------|-------------|---------|--------|
| `+` | Addition / string concatenation | `5 + 3` | `8` |
| `-` | Subtraction | `10 - 4` | `6` |
| `*` | Multiplication / string repetition | `"ha" * 3` | `"hahaha"` |
| `/` | Division | `10 / 3` | `3.3333...` |
| `%` | Modulo (remainder) | `10 % 3` | `1` |
| `-band` | Bitwise AND | `0xFF -band 0x0F` | `15` |
| `-bor` | Bitwise OR | `0x01 -bor 0x02` | `3` |
| `-bxor` | Bitwise XOR | `0xFF -bxor 0x0F` | `240` |
| `-bnot` | Bitwise NOT | `-bnot 0` | `-1` |
| `-shl` | Shift left | `1 -shl 4` | `16` |
| `-shr` | Shift right | `16 -shr 2` | `4` |

### Assignment shorthand

```powershell
$x = 10
$x += 5     # $x = 15
$x -= 3     # $x = 12
$x *= 2     # $x = 24
$x /= 4     # $x = 6
$x %= 4     # $x = 2
$x++        # $x = 3
$x--        # $x = 2
```

---

## Comparison Operators

PowerShell comparison operators are **case-insensitive by default**. Prefix with `c` for case-sensitive or `i` for explicit case-insensitive.

| Operator | Meaning | Example |
|----------|---------|---------|
| `-eq` | Equal | `"a" -eq "A"` → `$true` |
| `-ne` | Not equal | `1 -ne 2` → `$true` |
| `-gt` | Greater than | `5 -gt 3` → `$true` |
| `-lt` | Less than | `3 -lt 5` → `$true` |
| `-ge` | Greater or equal | `5 -ge 5` → `$true` |
| `-le` | Less or equal | `4 -le 5` → `$true` |
| `-like` | Wildcard match | `"hello" -like "h*"` → `$true` |
| `-notlike` | Wildcard not match | `"hello" -notlike "z*"` → `$true` |
| `-match` | Regex match | `"abc123" -match "\d+"` → `$true` |
| `-notmatch` | Regex not match | `"abc" -notmatch "\d+"` → `$true` |
| `-contains` | Collection contains | `@(1,2,3) -contains 2` → `$true` |
| `-notcontains` | Collection not contains | `@(1,2,3) -notcontains 5` → `$true` |
| `-in` | Value in collection | `2 -in @(1,2,3)` → `$true` |
| `-notin` | Value not in collection | `5 -notin @(1,2,3)` → `$true` |
| `-is` | Type check | `42 -is [int]` → `$true` |
| `-isnot` | Negative type check | `"a" -isnot [int]` → `$true` |

### Case-sensitive variants

```powershell
"Hello" -ceq "hello"    # $false (case-sensitive equal)
"Hello" -ieq "hello"    # $true  (explicit case-insensitive)
"Hello" -clike "H*"     # $true
"hello" -clike "H*"     # $false
"ABC" -cmatch "[A-Z]+"  # $true
```

### Array filtering with comparison operators

When the left side is an **array**, comparison operators return matching elements:

```powershell
1,2,3,4,5 -gt 3        # → 4, 5
"cat","dog","cow" -like "c*"  # → "cat", "cow"
"apple","banana","cherry" -match "^[ab]"  # → "apple", "banana"
```

---

## Logical Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `-and` | Both true | `$a -and $b` |
| `-or` | Either true | `$a -or $b` |
| `-not` / `!` | Negate | `-not $a` / `!$a` |
| `-xor` | Exactly one true | `$a -xor $b` |

### Short-circuit evaluation

`-and` stops at the first `$false`; `-or` stops at the first `$true`:

```powershell
$file = ".\config.json"
if ((Test-Path $file) -and (Get-Content $file -Raw | ConvertFrom-Json)) {
    "Valid config found"
}
```

---

## String Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `+` | Concatenate | `"Hello" + " World"` |
| `*` | Repeat | `"ab" * 3` → `"ababab"` |
| `-f` | Format | `"Hello, {0}!" -f "Alice"` |
| `-replace` | Regex replace | `"hello" -replace "l","r"` → `"herro"` |
| `-split` | Split by regex | `"a,b,c" -split ","` → `@("a","b","c")` |
| `-join` | Join array | `@("a","b","c") -join ","` → `"a,b,c"` |

```powershell
# -f format operator
"Today is {0:yyyy-MM-dd}" -f (Get-Date)
"{0,-15} {1,10:N2}" -f "Total", 1234.5

# -replace with regex groups
"John Smith" -replace "(\w+) (\w+)", '$2, $1'  # "Smith, John"

# -split with limit
"a:b:c:d" -split ":", 2   # @("a", "b:c:d")

# -join
("a","b","c") -join " | "  # "a | b | c"
```

---

## Redirection Operators

| Operator | Meaning |
|----------|---------|
| `>` | Redirect stdout to file (overwrite) |
| `>>` | Redirect stdout to file (append) |
| `2>` | Redirect errors to file |
| `2>>` | Append errors to file |
| `2>&1` | Redirect errors to stdout |
| `*>` | Redirect all streams to file |
| `*>>` | Append all streams to file |
| `3>` | Redirect warning stream |
| `4>` | Redirect verbose stream |
| `5>` | Redirect debug stream |
| `6>` | Redirect info stream |

```powershell
Get-Process > .\procs.txt           # overwrite
Get-Process >> .\procs.txt          # append
Get-ChildItem C:\ 2> .\errors.txt   # capture errors
Get-ChildItem C:\ 2>&1 | Out-File .\all.txt  # combine streams
```

---

## Range Operator `..`

```powershell
1..10        # array: 1 through 10
10..1        # array: 10 down to 1
'a'..'z'     # array: 'a' through 'z' (returns char in PS 7.4+, int in earlier versions)
foreach ($i in 1..5) { $i }
```

---

## Null-Coalescing and Null-Conditional Operators (PS 7+)

```powershell
# ?? null-coalescing
$value = $null
$value ?? "default"      # "default"
$value ??= "default"     # assign "default" to $value if null

# ?. null-conditional member access
$obj = $null
$obj?.Name               # $null (no exception)
$obj?.Method()           # $null (no exception)
```

---

## Ternary Operator (PS 7+)

```powershell
$age = 20
$status = $age -ge 18 ? "adult" : "minor"
```

---

## Pipeline Chain Operators (PS 7+)

```powershell
# && runs second command only if first succeeds
git pull && git push

# || runs second command only if first fails
Test-Path .\config.json || Write-Error "Config missing"
```
