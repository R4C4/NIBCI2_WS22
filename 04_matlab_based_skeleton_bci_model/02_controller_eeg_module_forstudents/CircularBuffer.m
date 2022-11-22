classdef CircularBuffer
    properties
        bufferSize;
        current_idx = 1;
        data;
    end
    methods 
        function obj = CircularBuffer(n, bufferSize)
            obj.bufferSize = bufferSize;
            obj.data = zeros(n, bufferSize);
        end
        
        function output = getLastNSamples(obj, n)
            if n > obj.bufferSize
                output = obj.data;
                return
            end
            if obj.current_idx -n < 1
                overhang = n - obj.current_idx;
                last_n = obj.bufferSize - overhang;
                output = zeros(size(obj.data,1), n);
                output(:,1:overhang) = obj.data(:,last_n+1:end);
                output(:,overhang+1:end) =  ...
                    obj.data(:,1:obj.current_idx);
            else
                output = obj.data(:,obj.current_idx - n: obj.current_idx);
            end
        end
        function obj = push(obj, data)
            chunk_size = size(data,2);
            if chunk_size > obj.bufferSize
                obj.data = data(:,end-obj.bufferSize+1:obj.bufferSize);
                return
            end
            if obj.current_idx + chunk_size > obj.bufferSize
                n_end = obj.bufferSize - obj.current_idx;
                n_start = chunk_size - n_end;
                obj.data(:, obj.current_idx+1:end) = ...
                    data(:,1:n_end);
                obj.data(:,1:n_start) = data(:,n_end+1:end);
                obj.current_idx = n_start;
            else
                obj.data(:, ...
                    obj.current_idx:obj.current_idx + chunk_size -1 ...
                    ) =  data; 
                obj.current_idx = obj.current_idx + chunk_size;
            end
        end
    end
end