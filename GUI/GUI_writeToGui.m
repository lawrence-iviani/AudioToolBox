function h=GUI_writeToGui(hText,str)
%Perform a simple write on a given text field
if ~isempty(hText) 
    h=hText;
    h.text{h.line}=[num2str(etime(clock(),h.initTime)) '-' str];
    set(h.textHandle,'String',h.text);
    h.line=h.line+1;
else
    warning('GUI_writeToGui: can''t write anything, handle null');
end
