This is a basic teletype created for the final Project of Hardware synthesis lab.

The teletype supports serial communication at 9600 baudrate with ISO-8859-11:2001 (Latin/Thai) or using 8 switches inputting ASCII code of your desired character. 
This supports Thai characters and basic English alphanumerics at a clock rate of 100MHz. Some unfrequently used characters might display incorrectly.

To use:
1. Connect your Basys3 board to your device.
2. Upload the bitstream to your Basys3 Board.
3. Connect your own Basys3 board's JA2 port to either your own Basys3 or any other Basys3's board JA1 port. The JA2 port serves as a transmitter for the data in ASCII either using the switches or USART with JA1 port as a receiver.
4. To communicate between two boards, repeat Step 3 for the other Basys3 board.
5. Connect your Basys3 board to a screen via VGA connection.
6. To reset your display, toggle switch 8.
7. For additional functionality, toggling switch 9 will mirror every character on your display with their positions remaining the same.
8. The 7 segments display will display the following: The 2 left displays indicate data being sent out in ASCII hexadecimal | The 2 right displays indicate data the board is receiving in ASCII hexadecimal.
