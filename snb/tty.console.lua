#!/usr/bin/env lua
-- tty console



function getch_unix() 
        os.execute("stty cbreak </dev/tty >/dev/tty 2>&1") 
        local key = io.read(1) 
        os.execute("stty -cbreak </dev/tty >/dev/tty 2>&1"); 
        return(key);       
end 

for i=1 , 5 do 
        io.write("Hit key==>") 
        local key = getch_unix() 
        io.write("\nYou pressed ") 
        io.write(key) 
        io.write("\n") 
end 