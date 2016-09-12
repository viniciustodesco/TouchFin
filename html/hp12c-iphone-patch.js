var avirgin = true;
var separator_status = 0;

Hp12c_storage.prototype.save = function() {
	localStorage.setItem('TOUCH12IF', H.storage.save_memory2(H.machine));
};

Hp12c_storage.prototype.load = function() {
	var sserial = "" + localStorage.getItem('TOUCH12IF');
  	if (sserial && sserial.length > 0) {
		H.storage.recover_memory2(H.machine, sserial);
	}
	avirgin = false;
};

var dontclick = 0;

Hp12c_machine.prototype.apocryphal = function (i)
{
    document.location = "touch12if:tclick:1";
    dontclick = 1;
};

var old_dispatch = Hp12c_dispatcher.prototype.dispatch;
var old_show = Hp12c_display.prototype.private_show;

Hp12c_dispatcher.prototype.dispatch = function (k)
{
  	old_dispatch.call(H.dispatcher, k);
	if (!avirgin) {
		H.storage.save();
	}
    if (separator_status != H.machine.comma) {
        separator_status = H.machine.comma;
        document.location = "touch12if:comma" + separator_status + ":1";
        return;
    }
    if (dontclick) {
        dontclick = 0;
    } else {
        document.location = "touch12if:click:1";
    }
}

function ios_separator(sep)
{
    while (H.machine.comma !== sep) {
        H.machine.toggle_decimal_character();
    }
    separator_status = H.machine.comma;
}

Hp12c_display.prototype.private_show = function (s)
{
	old_show.call(H.display, s);
	if (!avirgin) {
		H.storage.save();
	}
}

/*
window.addEventListener("load",function() {
  // Set a timeout...
  setTimeout(function(){
    // Hide the address bar!
    window.scrollTo(0, 1);
  }, 0);
});
*/

// coords supplied by another file
/*
H.disp_theo_width = 1024.0;
H.disp_theo_height = 656.0;
H.disp_key_offset_x = 8.0;
H.disp_key_offset_y = 210.0;
H.disp_key_width = 79;
H.disp_key_height = 69;
H.disp_key_dist_x = (941.0 - 8.0) / 9;
H.disp_key_dist_y = (554.0 - 210.0) / 3;
*/
