function REC = save_recording(REC)
    persistent rec_note_answers;
    
    prompts = {};
    prompts{1} = 'Name this recording';
    prompts{2} = 'Room';
    prompts{3} = 'Additional Notes:';
    if(isempty(rec_note_answers))
        rec_note_answers{1} = '';
        rec_note_answers{2} = '';
        rec_note_answers{3} = '';
    end
    while true
        tmp_ans = inputdlg(prompts,'Save the recording',[1 1 5],rec_note_answers);
        if(isempty(tmp_ans)), return; end
        rec_note_answers = tmp_ans;
        if(isempty(rec_note_answers{1})), return; end
        filename = [rec_note_answers{1} '_REC.mat'];
        if(exist(filename,'file'))
            choice = questdlg(['File ' filename ' exists.  Overwrite it?'],'Warning','No');
            switch(choice)
                case 'Yes'
                    break
                case 'No'
                    continue
                case 'Cancel'
                    return
            end
        else
            break;
        end
        
    end
    
    REC.name = rec_note_answers{1};
    REC.room = rec_note_answers{2};
    REC.notes = rec_note_answers{3};
    save(filename,'REC');
end