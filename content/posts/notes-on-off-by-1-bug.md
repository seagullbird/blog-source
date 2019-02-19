---
title: "Notes on Off-By-One Bug"
date: 2019-02-19T17:24:09-0500
draft: false
tags: ["Security"]
---

It is common sense that unsafe C library functions such as `strcpy`, `strcat`, `gets` and `scanf` may lead to buffer overflow attacks due to lack of boundary checks. There're "safe" versions of these functions such as `strncat` and `strncpy`. However, "safe" here is somehow misleading because there's also problem here, namely the "off-by-1" bug.

<!--more-->

## Intro

Man page excerpt of `strncat`:

```c
char *strncat(char *restrict s1, const char *restrict s2, size_t n);

The strncat() function appends not more than n characters from s2, and then adds a terminating '\0'.
```

Since `strncat` guarantees to append a terminating '\0', this '\0' might be written beyond the boundary of `s1`. Check out this example on wiki:

```c
void foo (char *s) 
{
    char buf[15];
    memset(buf, 0, sizeof(buf));
    strncat(buf, s, sizeof(buf)); // Final parameter should be: sizeof(buf)-1
}
```

15 bytes in `s` would be written to `buf` and `strncat` will write the last '\0' one byte beyond the actual length of `buf`. This is called an "off-by-1" bug.

Notice that,

> it is not consistent with respect to whether one needs to subtract 1 byte – functions like `fgets()` and `strncpy` will never write past the length given them (`fgets()` subtracts 1 itself, and only retrieves (length − 1) bytes), whereas others, like `strncat` will write past the length given them. So the programmer has to remember for which functions they need to subtract 1.

And since `strncpy` will never write past the length given, it may leave buffer unterminated (by '\0') instead.

## Attack

With *cdecl* convention on a x86 little endian machine, this "off-by-1" bug could lead to overwritting of the least significant byte (LSB) of the saved frame pointer (SFP). Suppose there's no callee saved values when calling a function, then what's after the SFP is local variables (Looking from top side down). [This article](http://theamazingking.com/tut4.php) explained in more detail about what we can do when we are able to change the SFP. Basically, because local variables are referenced relative to the value of `ebp`, if we are able to change the value of `ebp`, the program would refer to wrong values when trying to refer to its local variables.

> One approach that often helps avoid such problems is to use variants of these functions that calculate how much to write based on the total length of the buffer, rather than the maximum number of characters to write. Such functions include `strlcat` and `strlcpy`, and are often considered "safer" because they make it easier to avoid accidentally writing past the end of a buffer. (In the code example above, calling `strlcat(buf, s, sizeof(buf))` instead would remove the bug.)

## References

[Wiki](https://en.wikipedia.org/wiki/Off-by-one_error) and [this](http://theamazingking.com/tut4.php)

