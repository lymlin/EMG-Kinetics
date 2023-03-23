function data = ReshapeDataByIndex(Eseq,IndicesStim)
    % Index: n×m

    i = 1;
    Eseq = reshape(Eseq,[],[1]);
    data = [];

    for i = 1:size(IndicesStim,1)
        data = [data,Eseq(IndicesStim(i,:))];
    end
    
end

