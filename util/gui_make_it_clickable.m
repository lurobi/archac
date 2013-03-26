function gui_make_it_clickable(h,func,act)

    if(nargin<2 || isempty(func))
        ST = dbstack;
        func = ST(2).file;
    end
    if(nargin<3)
        act = get(h,'Tag');
    end
    
    set(h,'ButtonDownFcn',{func,act});
    
end