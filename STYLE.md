# MiscMod Coding Style Guide

In order to maintain consistency within the project, please maintain the
following coding style guidelines.

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”,
“SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to
be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

## Table of Contents

1.  [Lines](#lines)
    - [Indentation](#indentation)
    - [Conditional Statements](#conditional-statements)
    - [Comments](#comments)
    - [Readability](#readability)
2.  [Spacing](#spacing)
    - [Functions](#functions)
    - [Type Casting](#type-casting)
    - [Operators & Expressions](#operators--expressions)
        - [Operators](#operators)
        - [Expressions](#expressions)
3.  [Naming Conventions](#naming-conventions)
    - [Functions & Variables](#functions--variables)

## Lines

A line of code SHOULD be less than 120 characters in length. Preferably
less than 80 characters in length. All lines MUST use proper indentation and
line endings MUST be Unix-style LF.

### Indentation

The indentation MUST be exactly 4 spaces. No tabs.

### Conditional Statements

Multiple conditional statements SHOULD NOT be more than two per line and the
logical operator MUST be on the left hand side.

```cpp
// example - if statement with logical operator left hand side
if(this_function(param, param2) && this_other_function(param3, param4)
    && this_third_function()) {
    // ...
}
```

### Comments

Forward slash `// comment` SHOULD be used for comments. Multi-line comments
`/* comment */` SHOULD be avoided.

### Readability

Empty lines SHOULD be added where applicable for code readability.

## Spacing

### Functions

Opening `{` braces for top-level functions MUST be on their own line.

```cpp
some_function()
{
    // ...
}
```

Callback functions MUST contain spaces between the variable
and the `[[ ]]` brackets.

```cpp
var = ::myfunc;
[[ var ]](param);
```

### Statements

- Opening `{` braces MUST be placed on the same line as the statement they open.
- Closing `}` braces MUST be placed on their own line.
    - `else if` and `else` MUST be on the same line as the closing `}` brace separated by one space.
- Single-line statements MUST always omit bracing.
- In `switch-case` statements the `case`, `break`, `default` and `return` MUST be on the same indent.
- `for`, `while`, `if`, `else if`, `else`, `switch` MUST contain one space between the statement and the `{` brace.
- Between the statement name (e.g `if`) and the parenthesis MUST NOT contain white-space.

```cpp
// example - single-line statements
if(statement)
    do_this();
else
    do_that();

// example - multi-line code block with bracing
if(statement) {
    do_some_work();
    do_more_work();
    return true;
} else // single-line without braces
    return false;

// example - multi-line function call split across 3 lines
if(statement) {
    this_is_a_long_function_call(argument_that_is_long,
                                 argument_that_is_also_long,
                                 argument_three);
    // ...
} else
    other_thing();

// example - multi-line if statement with operator left hand side
if(this_condition
    && this_other_condition
    && some_other_thing) {
    actually_do_the_thing();
    // ..
} else
    something_else();

// example - nested ifs
if(statement) {
    if(something_else)
        do_this();
    else { // multi-line code block with bracing
        x = 10;
        do_that();
    }
}

// example - for loop, braces with one space
for(i = 0; i < 5; i++) {
    // multi-line ...
    i++;
}

// example - switch-case statement, always braces
switch(param) {
    case "on":
        thread on();
    break;
}
```

### Type Casting

Type casting MUST NOT contain a white-space between the type-cast
and the expression.

```cpp
isenabled = (bool)GetCvarInt(cvar);

myfloat = 3.1;
myint = (int)myfloat;
```

### Operators & Expressions

A space MUST be used between any expression, and any operators
and their operands:

#### Operators

Including, but not limited to:

**Arithmetic**

```cpp
+ - * / % ++ --
```

**Relational**

```cpp
== != < > <= >=
```

**Logical**

```cpp
&& || !
```

**Bitwise**

```cpp
^ & | ~
```

**Assignment**

```cpp
= += -= *= /= %= <<= >>= &= ^= |=
```

#### Expressions

Including, but not limited to:

```cpp
var = 1;
var = "string";

x = 1 + a;
x++;
i += 5;
```

## Naming Conventions

Function and variable names SHOULD be clear and concise and
express exactly what they do. Common sense MUST be used.

### Functions & Variables

- Functions SHOULD use all lowercase or camelCase.
    - Lowercase is preferred.
    - Non-lowercase multiple words function names MUST use camelCase.
- Existing and built-in functions MAY use CamelCase.
    - New and non-built functions MUST NOT.
- Built-in function names SHOULD be in their original CamelCase form when used.
- Variable names SHOULD use all lowercase.
    - Existing variables MAY use camelCase. New variables SHOULD NOT.
- `_` underscores MAY be used to separate words in the case of lowercase.

```cpp
// example - new functions
array_merge(param1, param2)
{
    // ...
    return array_merged;
}

countOnlineAlivePlayers(param)
{
    // ...
    return sum;
}

// example - existing built-in function
cvarint = GetCvarInt(param);

// example - exisiting custom function
isboltweapon = mod\functions::isBoltWeapon(sWeapon);
```