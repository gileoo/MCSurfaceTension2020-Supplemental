module Halton


// recursive implementation
let rec haltonR (b:int) (i) (f) (r) = 
    if i > 0 then
        let nf = f/(float b)
        haltonR b (i/b) nf (r + nf * float( i % b ))
    else
        r

let halton b i =
    haltonR b i 1.0 0.0

// mutable implementation 
let halton2 (b:int) i =
    let mutable f = 1.0
    let mutable r = 0.0
    let mutable ii = i

    while ii > 0 do
        f  <- f / (float b)
        r  <- r + f * float (ii % b)
        ii <- ii / b
    r

let haltonSeq numberBase size =
    seq{for i = 0 to size-1 do
            yield halton numberBase i }

let haltonSeq2 numBaseX numBaseY size =
    seq{for i = 0 to size-1 do
            yield (halton numBaseX i, halton numBaseY i) }

let test b size =
    for i = 0 to size-1 do
        if halton b i <> halton2 b i then
            failwith "result not matching"

 