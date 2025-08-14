---
layout: post
title:  "Excel Formula for Mixed Prefixes"
date:   2025-07-31
tags: [Reboot, Ubuntu]
---

# Excel Formula for Mixed Prefixes
You have **mixed prefixes** like:

-   `TB2`, `G100`, `MB99`, `CT1234`, `CC45`  
    ...and you want to format them all as:
    
-   `TB2` → `TB000002`
    
-   `G100` → `G000100`
    
-   `MB99` → `MB000099`
    
-   `CT1234` → `CT001234`
    
-   `CC45` → `CC000045`
    

----------

### Final Excel Formula (for any prefix + number → padded to 6 digits)

Use this in **cell B2**:

```excel
=LEFT(A2, MIN(FIND({0,1,2,3,4,5,6,7,8,9}, A2&"0123456789"))-1) & TEXT(MID(A2, MIN(FIND({0,1,2,3,4,5,6,7,8,9}, A2&"0123456789")), LEN(A2)), "000000")
```

----------

### What It Does:

-   Extracts the **prefix** (any number of letters).
    
-   Extracts the **numeric part**.
    
-   Pads the number to **6 digits**.
    
-   Joins prefix and padded number.
    

----------

### Example Results:

|  A (Original)| B (Formatted) |
|--|--|
| TB2 | TB000002 |
|G100|G000100|
|MB99|MB000099|
|CT1234|CT001234|
|CC45|CC000045|
|||

----------

### How to Apply

1.  Paste your original data in **Column A** (starting from A2).
    
2.  Paste the formula in **cell B2**.
    
3.  Drag down to B5500 (or double-click the fill handle).
