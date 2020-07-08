open System
open Halton
open Helper

[<EntryPoint>]
let main argv = 
    let size = 4096

    Halton.test 2 size
    Halton.test 3 size

    let exportCppArray prefix (arr:(float*float)[]) =
        use sw = System.IO.File.CreateText( sprintf "./%s.hpp" prefix )
 
        sw.WriteLine (sprintf "#ifndef %s_HPP" (prefix.ToUpper())) 
        sw.WriteLine (sprintf "#define %s_HPP" (prefix.ToUpper())) 
        sw.WriteLine "\n\n#include <vector>"
        sw.WriteLine (sprintf "\n\nstd::vector<float> %s = { " prefix)
        sw.Write "    "

        arr
        |> Array.iteri( fun i x -> 
            if i < arr.Length-1 then
                sw.Write (sprintf "%f, %f, " (fst x) (snd x))
            else
                sw.Write (sprintf "%f, %f " (fst x) (snd x))
            if (i+1) % 10 = 0 then
                sw.Write "\n    "
            )

        sw.WriteLine "};\n#endif"


    let toVec3 (h1) (h2) (radius) =
        let theta = 2.0 * System.Math.PI * h1
        let phi   = acos( 1.0 - 2.0 * h2 )

        let r_sin_phi = radius * sin( phi )

        (   r_sin_phi * cos( theta ),
            r_sin_phi * sin( theta ),
            radius * cos( phi ) ) 

    let exportCppVec3Array prefix (arr:(float*float)[]) =
        use sw = System.IO.File.CreateText( sprintf "./%s.hpp" prefix )
 
        sw.WriteLine (sprintf "#ifndef %s_HPP" (prefix.ToUpper())) 
        sw.WriteLine (sprintf "#define %s_HPP" (prefix.ToUpper())) 
        sw.WriteLine "\n\n#include <vector>"
        sw.WriteLine (sprintf "\n\nstd::vector<float> %s = { " prefix)
        sw.Write "    "

        arr
        |> Array.iteri( fun i x -> 
            let vx, vy, vz = toVec3 (fst x) (snd x) 1.0
        
            if i < arr.Length-1 then
                sw.Write (sprintf "%.15f, %.15f, %.15f, " vx vy vz)
            else
                sw.Write (sprintf "%.15f, %.15f, %.15f " vx vy vz)
            if (i+1) % 10 = 0 then
                sw.Write "\n    "
            )

        sw.WriteLine "};\n#endif"


    let doHaltonPair size a b  =
        let haltonPts = 
            Halton.haltonSeq2 a b size
            |> Seq.toArray

    (*
        let splitAndOffset (arr:(float*float)[]) =
            let a, b = arr |> Array.splitAt( arr.Length / 2 )
            let scaleA    = a |> Array.map( fun x -> (0.5 * (fst x), snd x) )
            let scaleOffB = b |> Array.map( fun x -> (0.5 + 0.5 * (fst x), snd x) )

            scaleA |> Array.append scaleOffB

        let haltonDoubleX = splitAndOffset haltonPts         
    *)
        let pointsModel = createPointsModel haltonPts (sprintf "Halton%d%d" a b)
        showChartAndRun (sprintf "Halton%d%d" a b) pointsModel
        exportPDF "." (sprintf "Halton%d%d" a b) pointsModel
        exportCppArray (sprintf "halton%d%d" a b) haltonPts 
        exportCppVec3Array (sprintf "haltonVec3%d%d" a b) haltonPts 

    let doRandomPair size seed =
    
        let rnd = System.Random( seed ) 
    
        let randomPts = 
            seq{
                for i = 0 to size-1 do            
                    yield ( rnd.NextDouble(), rnd.NextDouble() )
                }
            |> Seq.toArray

        let pointsModel = createPointsModel randomPts (sprintf "Random%d" seed)
        showChartAndRun (sprintf "Random%d" seed) pointsModel
        exportPDF "." (sprintf "Random%d" seed) pointsModel
        exportCppArray (sprintf "random%d" seed) randomPts
        exportCppVec3Array (sprintf "randomVec3%d" seed) randomPts 
 
    (*
        let pointsModelDoubleX = createPointsModel haltonDoubleX (sprintf "Halton2X%d%d" a b)
        showChartAndRun (sprintf "Halton2X%d%d" a b) pointsModelDoubleX
        exportPDF "." (sprintf "Halton2X%d%d" a b) pointsModelDoubleX
        exportCppArray (sprintf "halton2X%d%d" a b) haltonDoubleX 
    *)

    let doBlueNoiseTable cols samples =
    
        let blueNoise = BlueNoise.WangTileSet()
    
        printfn "Computing blue noise samples, this may take some minutes!"

        blueNoise.Generate( cols, samples, 12 )

        let bluePts =
            seq{
                for t in blueNoise.tiles do
                    for d in t.distribution do
                        yield (float d.x, float d.y )
            }
            |> Seq.toArray

        let pointsModel = createPointsModel bluePts (sprintf "Blue%d%d" cols samples)
        showChartAndRun (sprintf "Blue%d%d" cols samples) pointsModel
        exportPDF "." (sprintf "blue%d%d" cols samples) pointsModel
        exportCppArray (sprintf "blue%d%d" cols samples) bluePts
        exportCppVec3Array (sprintf "blueVec3%d%d" cols samples) bluePts 


    let nr = 16384 // 4096 // * 4

    doHaltonPair nr 2 3
    doHaltonPair nr 3 4
    doHaltonPair nr 4 5
    doHaltonPair nr 5 6

    doRandomPair nr 0

    doBlueNoiseTable 1 nr 

    0
