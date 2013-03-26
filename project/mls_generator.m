function out = mls_generator(order)

    a = zeros(2^order - 1,order,'int32');
    a(1,:) = 1;
    % m=4  = a_{i+4}  = a_{i+1} + a_{i}
    % m=19 = a_{i+19} = a_{i+6} + a_{i+5} + a_{i+1} + a_{i}
    % m=20 = a_{i+20} = a_{i+3} + a{i}
    
    %fprintf('%8d: ',1);
    %fprintf('%1d',a(1,end:-1:1));
    %fprintf('\n');
    for jj = 2:2^order
        a(jj,1:end-1) = a(jj-1,2:end);
        switch(order)
            case 4
                a(jj,end) = a(jj-1,2) + a(jj-1,1);
            case 20
                a(jj,end) = a(jj-1,4) + a(jj-1,1);
            
            otherwise
                error('MLS of order %d is not implemented.',order);
        end
        a(jj,end) = mod(a(jj,end),2);
        %fprintf('%8d: ',jj);
        %%% print it backwards so we can check our work (jkemp thesis)
        %fprintf('%1d',a(jj,end:-1:1));
        %fprintf('\n');
    end
    
    out = zeros(2^order,1,'int32');
    for n = 1:order
        out = out + (2^(n-1)).*a(:,n);
    end

end