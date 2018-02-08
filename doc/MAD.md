# MAD Instruction
In GPU's, there is a special instruction known as the MULTIPLY-ADD, or MAD.
The MAD instruction chains together a multiply and an add, ie `x * y + a`, such that the computation takes only a single cycle, versus the two plus cycles an add-multiply or other instruction chains will take.

# MAD Simplification
Keep an eye out for any constant values you could roll into a constant expression.

`(x - y) * a`         -->   `x * a + (-y * a)`
`(x - a) / (b - a)`   -->   `x * (1 / (b - a)) + (-x / (b - a))`
`(x - a) / b + 0.5`   -->   `x * (1 / b) + (0.5 - a / b)`
`x * (1.0 - x)`       -->   `x - x * x`
`x * (y + 1)`         -->   `x * y + x`
`(x + a) * (x - a)`   -->   `x * x + (-a * a)`
`(x + a) / b`         -->   `x * (1 / b) + (a / b)`
