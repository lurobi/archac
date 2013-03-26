function gui_gen_pos(pos_or_h,direction,wh)

    if(length(pos_or_h)>1)
        old_pos = pos_or_h;
    else
        set(pos_or_h,'Units','Inches');
        old_pos = get(pos_or_h,'Postion');
    end
    
    new_pos = old_pos;
    new_pos(3:4) = wh;

    h_buf = 0.1;
    w_buf = 0.1;
    
    L=1;B=2;W=3;H=4;

    switch(direction)
        case {'up','above'}
            new_pos(B) = old_pos(B) + old_pos(H) + h_buf;
        case {'right'}
            new_pos(L) = old_pos(L) + old_pos(W) + w_buf;
        otherwise
            error('You were too lazy to implement left or down!');
    end

end