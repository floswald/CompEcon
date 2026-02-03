using Random

function create_large_binary_file(filepath, size_gb)
    n_float64 = Int(size_gb * 1e9 / 8)  # each Float64 is 8 bytes
    chunk_size = 10^8  # write 100 million at a time
    
    open(filepath, "w") do io
        n_chunks = div(n_float64, chunk_size)
        remainder = rem(n_float64, chunk_size)
        
        for i in 1:n_chunks
            write(io, rand(Float64, chunk_size))
            println("Chunk $i/$n_chunks")
        end
        
        remainder > 0 && write(io, rand(Float64, remainder))
    end
    println("Created $(filesize(filepath) / 1e9) GB file")
    println("these are $n_float64 numbers with 8 bytes each")
end