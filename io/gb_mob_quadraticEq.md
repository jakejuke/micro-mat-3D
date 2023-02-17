# Quadratic Equations for GB Mobilities

Using the quadratic formula
$$ f(x) = ax^2 + bx + c $$
we can create a simple function to relate the GB mobility to misorientation.

| ![This is an image](../images/quadratics_examples.png) |
|:--:|
| *Quadratic functions that pass through $(0,0)$, are positive over $0 \lt x \lt 1$ and have a maximum of $1$.* |

To meet these conditons, there is only one independent variable $a$, the range of which is limited.
$$ -4 \leq a \leq -1$$

The condition $(0,0)$ forces $c=0$.

The 1st and 2nd derivatives of $f(x)$ are:

$$ f'(x) = 2ax + b $$

$$ f''(x) = 2a $$

In order to get a maximum in the function, the 2nd derivative must be negative. This implies that $a \lt 0$.

The maximum is located at $f'(x)=2ax+b=0$, which implies that $x = -b/2a$. If we evaluate $f(x)$ at this point and set it equal to $1$, then we can solve for the relationship between $a$ and $b$, keeping in mind that $a \lt 0$.

$$ f(x=\frac{-b}{2a}) = a\left(\frac{-b}{2a}\right)^2 + b\frac{-b}{2a}  = 1$$

$$ \frac{b^2}{4a} - \frac{b^2}{2a} = -\frac{b^2}{4a} = 1 $$

$$ b = \sqrt{-4a} = \sqrt{4|a|} = 2\sqrt{|a|} $$

