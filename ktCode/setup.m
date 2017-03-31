temp = pwd;
current_dir = temp(1:length(temp)-6);
path(path,[current_dir,'\FullBNT']);
path(path,[current_dir,'\ktCode']);
path(path,[current_dir,'\FullBNT\BNT']);
global BNT_HOME;
BNT_HOME = [current_dir,'\FullBNT'];
add_BNT_to_path;