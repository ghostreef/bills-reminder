$(document).ready(function () {

    // for update form
    $('.js-sources_table input, .js-sources_table select').change(function () {
        $(this).addClass('js-modified');
    });

    $('.js-update_many_sources_form').submit(function (e) {
        e.preventDefault();
        // jquery clone doesn't keep select or textarea values
        $(this).append($('.js-modified').remove().hide());
        this.submit();
    });

    // NOTE transformations uses this too       make generic later
    // for create form
    $('.js-add_fieldset').on('click', function(event) {
        var $fieldset = $('.js-source_fieldset:first').clone();
        $('input, select', $fieldset).val('');
        $(this).parent().append($fieldset);
    });
});

// copy text from regex field and move over to name field
$(document).on('click', '.js-fill_in_name', function () {
    if($(this).siblings('.js-regex').val() == ''){
        return;
    }
    var regex = $(this).siblings('.js-regex').val().split(' ');

    for(var i = 0; i < regex.length; i++) {
        regex[i] = regex[i][0].toUpperCase() + regex[i].substr(1).toLowerCase();
    }

    regex = regex.join(' ');

    $(this).siblings('.js-name').val(regex);
});

$(document).on('click', '.js-fill_in_all', function () {
    $('.js-fill_in_name').click();
});

$(document).on('click', '.js-remove_source', function () {
    $(this).parents('.js-source_fieldset').remove();
});