-- "addons\\homigrad\\gamemodes\\homigradcom\\gamemode\\cl_init.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
include("shared.lua")

/*
⠀⠀⣠⣿⣿⠿⠿⠿⠷⠶⣦⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⡶⠶⠿⠿⠿⢿⣿⣧⡀⠀⠀
⠲⣿⡟⠉⠀⠀⢀⣤⣶⣶⣶⣍⠛⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠟⢋⣴⣶⣶⣶⣄⠀⠀⠈⠙⣿⡷⠂
⠀⢹⡇⠀⠀⠀⠈⠈⢰⣤⣾⡟⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢽⣦⣴⠞⠙⠀⠀⠀⠀⣿⠃⠀
⠀⠀⢷⠀⠀⠀⠀⠘⠂⠉⠁⠠⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠣⠂⠉⠁⠀⠈⠀⠀⠀⢰⠃⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⢀⠀⢀⠔⢋⡠⢀⡀⠀⣀⠄⣀⠔⠀⠀⠀⠀⠀⠀⠀⠀⢀⡤⠀⠀⠀⠀⠀
⠀⢀⠔⢀⡤⠀⡠⠒⣀⠝⡡⠚⢁⠔⢋⠔⠉⡠⠞⡡⠞⠁⡠⠚⠀⣀⠄⠉⢁⠤⠊⠁⡠⠔⠉⠀⠀⠀
⠐⡡⠚⢁⠔⠉⡠⢊⠵⠊⡠⠖⡡⠚⢁⠤⢊⡠⠊⢀⠔⠊⢀⠴⠊⣠⠔⠊⢁⡤⠒⢉⠤⠂⠀⠀⠀⠀
⠈⠀⠞⠁⡴⠊⠀⠁⠠⠊⠔⠋⢀⠔⢁⠔⠉⣠⠾⣁⠀⠐⠁⠒⠉⠀⠤⠚⠁⠀⠊⠁⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠁⢀⣌⣀⣀⣀⣡⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡾⠿⢿⣿⡿⠿⢿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠆⠀⠀⠀⠀⣂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⢄⠀⠀⠀⠀⠀⢀⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠃⠑⠀⠀⠀⠐⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠠⣢⣿⣿⣿⣵⣿⣧⣀⠀⠑⢪⢱⣨⣾⣿⣿⣿⣿⣿⣷⣿⣿⣄⡱⢊⠵⣉⢮⡑⣿⣿⣿⣿⣿⣟⣄⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣶⣿⣿⣿⣿⡿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣷⣶⣿⣿⣿⣿⣿⣿⣿⣎⣆⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⢟⣽⣿⢇⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⢻⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⡈⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣿⣿⣿⣿⣏⢮⣿⣿⣢⣿⣿⣿⣿⣿⣸⣿⣷⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣸⣿⣿⣿⡯⣽⣿⣿⣿⣿⣿⣿⣿⣧⣀⣀⣀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣾⣿⠟⣩⣶⣿⣿⢎⣿⣿⣿⣿⣿⣳⡗⡿⡏⠹⡿⣽⣿⢯⣿⢿⣟⣿⣿⢿⣿⣿⣿⣿⠹⣿⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣴⣾⣿⡿⣟⣷⣣⣾⣿⣿⣿⣿⣻⣿⣿⣿⣿⣿⡟⠀⢹⡇⠀⢿⡽⣯⡳⣽⣺⡝⣾⣹⣿⡟⡟⣿⡏⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⡿⠿⠛⣫⣽⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣧⣴⣶⣿⢶⣜⣿⣻⢗⡼⡇⡼⣸⣿⣟⣼⣳⣿⣷⣦⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡾⠛⠉⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⡏⠀⢿⣿⣿⣿⡟⢿⠿⠚⠛⠁⡿⢸⡿⠋⠹⣿⣿⣾⣿⡿⣿⣿⣿⣟⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡐⣸⠉⠀⠀⢀⣮⣿⡿⠋⠱⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽⣿⡄⠙⠤⣘⢏⠐⠊⠁⠀⠀⢀⠀⠀⠀⠀⠀⠈⠂⠿⢟⣛⣿⠋⡱⣻⡟⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠣⠀⠀⢀⢸⣿⣿⣧⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⣧⠰⡢⡪⣣⠔⠀⠀⠀⢄⣮⠀⠀⠀⠀⠀⠀⢀⠔⢀⠀⠈⢉⢁⣷⣟⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠃⠸⠐⠄⠂⠁⠈⣿⣿⣿⣆⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻⣿⡞⣿⢿⡔⠋⠊⠊⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠐⠁⡠⡲⢃⢎⣾⡧⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⢿⣿⣿⡾⣿⣿⣼⣮⡍⣦⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠎⠀⡎⣾⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡀⠀⡇⠀⠀⠀⠀⠀⢹⣿⣘⡿⣿⣿⣿⣿⣿⣿⣿⢧⠙⣿⣿⣿⣿⣿⣿⣏⡇⢂⠈⠀⠀⠀⠀⢀⣀⣀⢀⣀⠀⠀⠀⠀⠀⠀⣀⢤⡾⠋⣼⡿⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢄⠹⣄⠸⣆⠀⠀⠀⠀⠀⣿⣯⣿⣿⣿⣿⣿⣿⣿⠉⠻⡆⢻⣿⣿⣿⣻⣧⢿⣝⡄⠡⡀⠀⠀⠀⠈⠁⠀⠀⠀⠈⠁⠀⠀⠀⠀⠂⠉⢀⣼⣿⣱⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⢀⡥⣾⠃⠀⠀⠀⠀⠀⠀⠀⠀⠈⠈⢗⠒⠍⠀⠀⢀⣰⣿⣷⣿⠿⠛⠛⠛⠛⠻⠄⡀⢸⣼⣿⣿⣿⣽⣟⣾⣻⡼⢶⣌⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⣽⡿⣿⣿⣿⣿
⢲⠲⢾⣤⣱⠆⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣴⣶⣶⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⡙⣿⣿⣿⣿⣿⣿⣷⣟⣿⣷⢮⣷⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⣍⠛⣰⡇⢻⣿⣿⣿
⢦⠑⣸⢱⠀⠈⢆⠀⠀⠀⠀⠀⠀⠎⡎⠀⠀⠀⠀⢀⣴⣾⠟⠁⠀⠀⠠⠀⠀⠀⠀⠀⠀⣠⡟⢸⣿⣿⣟⣿⣿⡹⢿⣿⣿⣷⣻⠇⣻⣦⣄⣀⣀⣤⣴⡶⢛⠭⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠻⠕⠈⢠⠏⣧⠊⣿⣿⣿
⠀⠀⢀⡾⠉⠄⠈⠆⠀⠀⠀⠀⠀⠣⠐⡀⠀⠀⡔⠻⡿⠃⠀⠀⠀⠀⠀⢉⠒⠀⢀⠲⠊⠹⢿⣾⣿⢿⣯⡝⡹⢛⠷⣞⢻⣛⡇⠡⢠⠙⡾⡱⠯⠞⡡⠜⡡⢾⣿⣿⣿⣿⣿⣿⣿⡿⠁⡀⢂⣄⡼⠋⡰⠹⣆⢹⣿⣿
⠀⠀⠎⠀⠀⠀⠀⠈⡄⠀⠀⠀⠀⠀⠀⠨⣆⠀⠆⠴⠓⢉⣉⠿⠷⠶⣲⠾⣖⣉⠀⠀⠀⠀⣸⣿⢯⡿⠙⢿⣔⡉⠖⡈⠖⣼⠃⡔⠀⠐⠠⠑⠈⠄⠁⢌⣱⣿⣿⣯⣿⣿⣿⣿⢿⠀⠠⠐⠠⣀⣤⠚⠀⠀⠘⣼⣿⣿
⠀⠈⠀⠀⠀⠀⡰⠀⡃⠀⠀⠀⠀⠀⠀⢀⠨⠑⠊⠉⠀⠀⠀⠀⠀⠀⠀⠉⠐⠋⠻⠶⢶⣾⣿⠽⠞⠁⠄⠂⠉⠻⣦⣍⠒⡨⢁⠇⠀⠁⠀⠀⠀⠠⢨⢶⠋⣿⣿⣿⣿⣿⣿⣏⣼⣷⣶⢾⠳⠋⠀⠀⠀⠀⠀⢸⣿⣿
⠀⠀⠀⠀⠠⠊⠀⠀⠇⠀⠀⠀⡀⠔⠨⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠢⡈⠠⠁⠌⡀⠀⠙⣧⠐⠡⠈⠀⠀⠀⠀⠀⣰⠋⢺⣠⣿⣿⣿⣿⣿⡿⢛⡋⢿⣧⡊⠄⠀⠀⠀⠀⢀⣀⣼⣿⣿
⠀⠀⠀⠀⠀⠀⡀⢸⠀⡠⡐⠌⠂⢁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠂⠠⠁⠄⠛⠀⠀⠀⠀⠀⠀⢀⣜⣁⣀⠸⣿⣳⢟⣿⣟⣹⡷⢦⣉⣖⡼⣟⣶⣤⠶⠶⠿⣛⢻⣿⣿⣿
⡀⠀⠀⠀⢀⢰⢖⡽⢮⠌⠀⠀⠠⠥⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⡠⢁⠈⡐⠠⠐⠀⢈⠀⡰⠟⠃⠉⠉⠙⠻⣧⡻⢿⡷⠬⢿⡆⠡⠈⠙⠒⠦⢴⡈⠬⠑⡌⣾⢟⠣⡟
⠠⠑⣈⠐⠀⠺⣯⢂⡿⢀⡀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡘⢄⠠⢊⠔⣁⢂⡁⠂⠀⠀⠀⠀⠀⣀⡀⠀⢇⠙⠻⡇⡇⠀⠳⡄⠁⠌⡐⡁⢆⡘⢳⡴⢫⠁⣎⣞⢱
⠀⠀⠀⢈⠀⣸⡟⠫⡔⠣⠜⡠⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠜⡠⠑⡌⢒⠠⠂⠀⠀⠀⢀⠔⠊⠁⠀⠀⠀⠀⠢⠀⢻⣱⠀⠀⠈⠓⠦⠐⢨⠐⢌⠢⢹⣶⣿⣯⣶⣿
⠀⠀⠈⠀⡐⢸⢡⠃⡌⡑⠃⠄⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠢⡘⣄⠋⡔⢁⠂⠀⠀⢀⠔⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠪⣷⣥⠴⠴⠀⠀⡐⠠⠈⠄⠂⠡⢸⡟⢥⠲⣌
⠀⠀⠠⠐⠀⣹⡀⠂⠄⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠢⣑⠲⠤⡉⠔⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠻⠶⢦⠤⢴⠆⠁⠀⠀⠁⠈⣗⣮⣷⢾
⠀⠀⠀⠀⠠⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⡐⠰⣠⠓⣌⢣⢃⡑⢢⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢢⠳⣼⠂⠀⠀⠀⠀⠀⢹⣟⡾⢋
⠀⠀⠀⠀⠀⠌⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠠⠀⠂⠌⡐⠰⣠⠓⡴⣩⢒⠣⢎⡘⠤⢁⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢱⢸⡇⠀⠀⠀⠀⠀⢸⣯⠑⡂
⠀⠀⠀⠀⠀⠘⡸⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠂⠁⠄⢂⠡⠘⣠⢑⡣⢖⣹⠲⣥⢋⠞⡰⣈⠒⠄⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢃⢻⡀⠀⠀⠀⠀⢸⡗⠘⡄
⠀⠀⠀⠀⠀⠠⡑⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠌⠠⢁⠌⡐⠄⣢⡵⢦⠛⡼⣙⠶⣙⢦⣋⠮⡑⠤⣉⠂⠡⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⠈⠄⠀⠀⠀⠀⠀⠸⣧⠀⠀⠀⠀⠀⣇⡘⠄
⠀⠀⠀⠀⠀⠠⡑⣿⡝⣳⢦⣀⠀⠀⠀⠀⠀⠀⠠⠁⢂⠠⢀⠂⢌⡐⣂⡶⡼⠾⡛⢅⢃⢚⠷⣩⠏⡝⢦⣣⡗⣉⠒⠄⡌⠁⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠢⠜⠀⠀⠀⡀⠀⡀⢼⡄⠀⠀⠀⠀⡧⢍⡳
⠀⠀⠀⠀⠀⠰⢡⡟⠠⠁⠛⠭⣟⣶⣤⣤⣀⣄⣡⣄⣦⣴⣦⠿⠞⡫⢙⠰⡁⢆⠱⡈⢆⢺⡹⣃⠞⡨⢍⣷⢺⢵⢈⠒⠠⠁⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⢂⠤⢁⠠⢸⡇⠀⠀⠀⠀⢹⡎⡵
⠀⠂⠀⠀⠠⢁⡿⠁⠀⠐⠀⠠⠀⠆⡜⣿⣟⡻⢏⡛⡋⢥⠂⡅⢣⠰⠁⠆⡑⠨⠄⡱⢈⡶⠃⠔⡨⢑⠞⠈⢯⢞⣆⠡⠂⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠢⢌⢢⣵⢾⣲⡡⠆⣸⠇⠀⠀⠀⠀⢸⡽⣱
⠀⡁⢀⠂⠁⠌⠀⠀⠀⠀⡐⠠⡁⢞⣼⣟⠮⣕⢫⠐⢥⠢⡑⠌⠢⠄⠉⠀⠀⠀⠀⠰⡙⠁⠈⠐⡠⠃⠀⠀⠈⢯⢾⡔⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢌⠱⣊⢽⣯⣿⣿⠧⣁⣿⠀⠀⠀⠀⠀⢸⣓⢧
⠀⡁⠈⠀⠄⠀⡀⢀⠀⠄⣁⢢⣱⣾⣿⡟⢶⡙⢌⠲⠌⠢⠁⠀⠀⠀⠀⠀⠀⠀⠀⠂⡁⠀⠀⡰⠃⠀⠀⠀⠀⠘⣎⢷⡂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠔⡩⢜⠻⢿⢋⠆⣹⡟⠀⠀⠀⠀⠀⠈⡿⣜
⠀⠄⠡⠀⠌⢀⢀⠂⣌⠲⣴⣿⣿⢿⣽⢙⠦⡑⡈⢂⠉⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠊⠀⠀⠀⠀⠀⠀⠀⠘⣆⠿⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠰⣈⠱⣸⠊⢴⣿⠃⠀⠀⠀⠀⠀⠈⡇⢞
⠀⡘⢄⠡⢊⡔⣌⣾⣴⣿⠿⠿⣽⣯⣿⡘⢢⠁⠐⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣎⡝⢶⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠐⡀⠢⢁⣬⡿⡹⠀⠀⠀⠀⠀⠀⢠⣇⠠
⠠⡑⣪⡵⠷⡞⠉⠁⠀⠀⠀⢸⣿⡷⡿⢁⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣎⡕⡻⣦⣄⠠⢀⠀⡀⠀⠀⠀⠀⠀⠀⠀⢀⡐⢠⢃⣾⢋⡔⠃⠀⠀⠀⠀⠀⠀⡿⡛⡐
⠀⠁⠘⣄⠣⡇⠀⠀⠀⠀⠀⢸⣿⡿⢁⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢶⡱⣉⠟⡷⣤⣂⠔⠡⢄⠠⠀⠄⡐⡈⣄⣶⣷⣿⣏⠒⡌⠀⠀⠀⠀⠀⠀⢸⢃⠔⠁
⠀⠀⠀⢳⠀⣇⠀⠀⠀⠀⠀⣿⣿⠃⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢳⣍⡚⠴⣡⠋⡟⣳⡞⣶⣿⣶⡟⢉⠡⠄⣈⠻⣮⠱⡀⠀⠀⠀⠀⠀⠀⠚⠀⡀⠂
⠀⠀⠀⠀⡆⠈⠀⠀⠀⢀⠎⣿⠇⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⢯⡑⢆⡹⢐⠏⡼⢉⡙⢻⣷⠠⠁⡌⢀⠒⣿⡡⠀⠀⠀⠀⠀⠀⠀⡀⠤⠒⠚
⠀⠀⠀⠀⠰⠀⠀⠀⢠⠊⢀⡏⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢏⠆⡰⣋⡾⢁⠂⠜⢠⠻⣧⡑⠠⠌⠂⠽⡇⠀⠀⠀⢀⡠⠒⠁⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⡸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠎⡐⢀⢸⡃⢆⢈⠘⢄⡘⢧⢏⡱⢌⠘⡈⣷⠀⣀⠔⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⡉⠑⠒⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡘⢰⢻⣿⣇⠌⡄⠊⡄⡘⢌⢮⠱⢌⢂⠡⡿⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⢎⠆⠈⠢⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⠀⠻⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠌⢢⢻⢻⣿⣾⣤⣃⡔⡈⢆⢪⡑⢎⡴⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⠔⠑⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠢⠈⠂⢄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠆⡏⢧⠻⡿⣿⣿⣿⣿⣾⣦⠝⡁⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⡤⠃⠀⠀⠈⢆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠱⠘⡄⢣⠜⢎⠻⣿⡿⠏⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⡰⠉⠀⠀⠀⠀⠀⠀⢂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⡌⡒⢌⣲⠷⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣠⠎⠀⠀⠀⠀⠀⠀⠀⠀⠀⠢⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⢠⣳⠞⠁⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠑⠠⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⣀⠠⠄⠂⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠑⠄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡿⠀⠀⠀⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⢢⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡗⠀⠀⢈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠹⡗⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠼⠁⠀⠀⠸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⡌⠢⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⠁⠀⠀⠀⠸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣌⢦⠑⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣹⣧⣠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠃⠀⠀⠀⠀⡀⠀⠀⠀⡔⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠦⠆⠀⠉⠢⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣸⣿⣿⣿⣄⢠⣠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢎⠀⢀⠀⠀⠀⢀⠁⠀⠀⠌⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡐⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⡠⢉⠀⢀⠀⠀⠀⠀⠀⠀⣶⣾⣿⣿⣿⣿⣿⣿⣾⣗⠶⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠃⡌⠂⠄⠀⠀⠀⠌⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡐⠠⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢳⡞⡆⡘⢆⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣷⣿⠿⠀⠀⠀⠀⠀⠀⠀⠀⢀⢇⡇⠃⠆⠘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⢀⠃⡀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣝⡔⢢⠑⣄⠀⠀⠀⠀⠀⢬⣿⣿⣿⡿⣟⡼⠃⠀⠀⠀⠀⠀⠀⠀⠀⣜⡮⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⡀⢂⠐
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢎⠧⣍⠔⡠⠂⠄⠠⠐⢂⢿⣿⣟⣟⣮⡧⢑⠂⡄⡀⠠⡀⢄⣠⢏⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠇⠢⠌
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⢌⢧⡡⢃⠬⡁⡘⠌⡼⣖⣿⣻⢾⣣⠣⡘⠤⢁⠣⠜⣤⢓⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠠⡁
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠣⡧⢍⢆⠳⢠⠉⠖⣯⢞⣿⡝⣮⡑⠤⢃⢎⡱⣍⢦⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠃⡔
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣮⣎⠱⢢⠙⡌⣿⢺⣿⣷⡸⣇⢃⠎⡶⡱⣮⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠽⣧⣇⡱⢈⢻⡭⣟⣿⣷⠇⣎⠼⣱⣿⠃⠄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠢⢍⠽⢷⣍⡒⣻⣽⣿⣟⡯⣜⣯⡟⠡⢌⠂⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⢎⡸⢌⠽⣷⣬⡻⣿⣿⢯⣽⡟⣌⠓⡌⠰⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠢⠔⡩⢒⠬⣻⣷⣻⣼⣳⣿⡹⢦⡙⠤⢃⠡⠈⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡑⢨⠐⣍⠲⡡⢞⣿⣳⣟⣾⡽⡲⣍⠚⡤⢁⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠌⡀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⢀⠃⠜⡠⢣⣑⢫⢖⡻⣽⣞⡷⡳⣌⢳⠰⡈⠄⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠
*/