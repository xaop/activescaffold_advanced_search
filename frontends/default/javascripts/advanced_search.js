function asAddCriterion(element) {
  //$(element).up(".as_inputs");
  var fields = $("as_template").cloneNode(true);
  fields.id = null;
  fields.style.display = "block";
  element = $(element).up(".as_inputs");
  element.parentNode.insertBefore(fields, element);
  new TextFieldWithExample(fields.down("input"), 'Search Term');
}

function asRemoveCriterion(element) {
  element = $(element).up(".as_criterion");
  element.parentNode.removeChild(element);
}
