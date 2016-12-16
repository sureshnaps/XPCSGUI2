function updatemessage(newstr)
% ---
% --- FUNCTION UPDATEMESSAGE(NEWSTR)
% ---
% --- This function updates the message on the XPCSGUI main window with
% --- the string provided by "NEWSTR"
% --- The Newstr is pasted in front of the old string!
% ---
% --- by MS 20080519
% ---
hFigXPCSMain = findall(0,'Tag','xpcsmain_Fig')                             ; % find the XPCSGUI main window
% ---
msgstr = get(findall(hFigXPCSMain,'Tag','xpcsmain_EditMessage'),'string')  ; % get existing message string
% ---
set(findall(hFigXPCSMain,'Tag','xpcsmain_EditMessage')                  ...
   ,'String',[newstr;msgstr],'HorizontalAlignment','left')                 ; % add the new string to the beginning

% ---
% EOF
