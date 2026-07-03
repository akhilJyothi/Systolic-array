# Systolic Array

Systolic array is a grid of Multiply-Accumulate(MAC) units and is used for efficient matrix multiplication and other linear algebra applications . These are used in CNN were better speed for matirx multiplication matters.

First a mac unit which simply does the job of acc<=acc +(a_in*b_in) was implemented.
Then this was used in a 2x2 systolic array.
The 2x2 systolic array we mannually wired and the simulations showed this was working pefectly.

Later this mac unit was used to build a parameterized scaleable systolic array.
The design was generalized using parameters for array size and data width, enabling the same RTL to instantiate an N×N systolic array without requiring manual wiring. This scalable architecture can therefore be configured for different matrix dimensions while maintaining the same underlying design.
