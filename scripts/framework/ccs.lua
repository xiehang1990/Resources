local ccs = ccs or {}

ccs.TouchEventType = 
{
    began = 0,
    moved = 1,
    ended = 2,
    canceled = 3,
}

ccs.LoadingBarType = 
{ 
    left = 0, 
    right = 1,
}

ccs.CheckBoxEventType = 
{
    selected = 0,
    unselected = 1,
}

ccs.SliderEventType = 
{
    percent_changed = 0
}

ccs.TextFiledEventType = 
{
    attach_with_ime = 0,
    detach_with_ime = 1,
    insert_text = 2,
    delete_backward = 3,
}

ccs.LayoutBackGroundColorType = 
{
    none = 0,
    solid = 1,
    gradient = 2,
}

ccs.LayoutType = 
{
    absolute = 0,
    linearVertical = 1,
    linearHorizontal = 2,
    relative = 3,
}

ccs.UILinearGravity = 
{
    none = 0,
    left = 1,
    top = 2,
    right = 3,
    bottom = 4,
    centerVertical = 5,
    centerHorizontal = 6,
}

ccs.SCROLLVIEW_DIR = {
    none = 0,
    vertical = 1,
    horizontal = 2,
    both = 3,
}

ccs.PageViewEventType = {
   turning = 0,  
}

ccs.ListViewEventType = {
    init_child = 0,
    update_child = 1,
}

ccs.ListViewDirection = {
    none = 0,
    vertical = 1,
    horizontal = 2,
}

return ccs
