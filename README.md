# moonscheme
A Scheme R7RS Lisp hosted on Lua 5.2/LuaJIT 2.0.1

I had tried written a Scheme hosted Lua before, but I think I got too lost on making as spec compliant as possible, which meant wrapping everything in tables with metatables to enforce and check type safety. I think for this try, I am going to aim for speed, which means minimal boxing, and having the Scheme compile down to Lua always. This means that there is no interpreter, like Clojure. This also means that the compiler can't be too slow and that ```(eval)``` should not be used in a hot loop. This also means that code should be JIT friendly to LuaJIT, so I might have to run experiments to see what that means.

## Limitations
* No numeric tower, moonscheme numbers are Lua numbers (IEEE-754 64 bit floating point)
