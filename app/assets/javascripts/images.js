function bootstrap_modal_html(id, src, caption) {
	return '<div id="modal-' + id + '" class="modal fade image-modal">' +
           '<div class="modal-header">' +
             '<button type="button" class="close" data-dismiss="modal">×</button>' +
             '<h3>' + caption + '</h3>' +
           '</div>' + 
           '<div class="modal-body">' +
             '<img src="' + src + '" />' +
           '</div>' +
         '</div>'
}
function image_popup() {
	$("[data-behavior='image-popup']").on("click", function(){
		var image = $(this);
		if($("#modal-" + image.attr("id")).length == 0 ) {
			$("body").append(bootstrap_modal_html(image.attr("id"), image.attr("data-full-url"), image.attr("data-caption")));
		}
		$("#modal-" + image.attr("id")).modal("show");
	});
}
$(document).ready(function(){image_popup()});
document.addEventListener("page:load", function(){image_popup()});