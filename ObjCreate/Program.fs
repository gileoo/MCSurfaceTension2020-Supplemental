type vec3 =
    {
        X : float
        Y : float
        Z : float
    }

type tri2 =
    {
        A : int*int
        B : int*int
        C : int*int
    }

type tri1 =
    {
        A : int
        B : int
        C : int
    }

let to1D (arr:vec3[,]) (t:tri2) =
    
    let sx = Array2D.length1 arr

    let tIdx (i,j) = 
        i + sx * j
    
    {   A= tIdx t.A
        B= tIdx t.B 
        C= tIdx t.C }

module Func =
    let Saddle (s:float) (o:float) (x:int) (y:int) = 
        let xs = s * (float x) + o
        let ys = s * (float y) + o
        
        {   X= xs 
            Y= ys
            Z= xs*xs - ys*ys }

    let Sphere (s:float) (o:float) (r:float) (x:int) (y:int) = 
        let xs = s * (float x) + o
        let ys = s * (float y) + o
        
        {   X= xs 
            Y= ys
            Z= xs*xs - ys*ys }


let writeObj (fileName:string) (arr:vec3[,]) =
    use file = System.IO.File.CreateText( fileName )
    
    let sx = Array2D.length1 arr
    let sy = Array2D.length2 arr

    arr
    |> Array2D.iter( fun v -> 
        file.WriteLine( sprintf "v %f %f %f" v.X v.Y v.Z ) )

    arr
    |> Array2D.iteri( fun i j x -> 
        let t1 = 
            {   tri2.A= (i,j)
                B= (i+1,j)
                C= (i+1,j+1) }
            |> to1D arr

        let t2 = 
            {   tri2.A= (i,j)
                B= (i+1,j+1)
                C= (i,j+1) }
            |> to1D arr

        if i < sx - 1 && j < sy - 1 then
            file.WriteLine( sprintf "f %d %d %d" (t1.A+1) (t1.B+1) (t1.C+1) ) 
            file.WriteLine( sprintf "f %d %d %d" (t2.A+1) (t2.B+1) (t2.C+1) ) )


[<EntryPoint>]
let main argv =

    let len = 2.0
    let sizeX, sizeY  = (101, 101)
      
    let scale  = len / float(sizeX-1) 
    let offset = -(float (sizeX - 1))*scale/2.0 
    

    let verts = Array2D.init sizeX sizeY (Func.Saddle scale offset)

    verts
    |> writeObj (sprintf "Saddle%d%d.obj" sizeX sizeY) 


    printfn "%A" argv
    0 // return an integer exit code
