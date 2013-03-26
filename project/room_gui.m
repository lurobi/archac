function room_gui(action,cback_fig)

    if(nargin<1) action = 'init'; end
    if(~ strcmp(action,'init'))
        if(nargin<2) cback_fig=gcf; end
        if(~strcmp(get(cback_fig,'name'),'Room Characterization'))
            warning('room_gui called from wrong figure!');
            return;
        end
    end

    switch(action)
        case('init')    
            cback_fig = init_room_gui();
    end
    
    
end

function cback_fig = init_room_gui()
    cback_fig = figure();
    set(cback_fig,'Name','Room Characterization');
    
    WINDOW_HEIGHT = 5;
    WINDOW_WIDTH = 10;
    
    CW=.10;
    CH=.25;
    
    set(cback_fig,'Units','Inches','Position',[1,1,WINDOW_WIDTH,WINDOW_HEIGHT])
    
    panel_pos = [0 0 2 WINDOW_HEIGHT];
    uipanel(cback_fig,'Position',panel_pos,'Title','Waveform');
    
    pos = [0 0 13*CW, CH];
    h = uicontrol('Style','pushbutton','String','Make Waveform','Units','Inches','Position',pos);
    
end