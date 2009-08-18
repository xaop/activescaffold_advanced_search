function asAddCriterion(element, type_map) {
  var fields = $("as_template").cloneNode(true);
  fields.id = null;
  fields.style.display = "block";
  element = $(element).up(".as_inputs");
  element.parentNode.insertBefore(fields, element);

	// If more than one criterion display boolean field
	if (element.previous('.as_criterion').previous('.as_criterion') != undefined) {
		element.previous('.as_criterion').down().show();	
	}

  var as_field = fields.down(".as_field");
  as_field.observe("change", function (event) { asUpdateSearchType(as_field, type_map); });
  asUpdateSearchType(as_field, type_map);
  new TextFieldWithExample(fields.down("input"), 'Search Term');
}

function asUpdateSearchType(element, type_map) {
  var container = element.up(".as_criterion");
  switch (type_map[element.getValue()]) {
    case "integer" :
      container.down(".as_negator").show();
      container.down(".as_matcher").hide();
      container.down(".as_search").hide();
      container.down(".as_b_matcher").hide();
      container.down(".as_i_matcher").show();
      container.down(".as_i_search").show();
      break;
    case "text" :
      container.down(".as_negator").show();
      container.down(".as_matcher").show();
      container.down(".as_search").show();
      container.down(".as_b_matcher").hide();
      container.down(".as_i_matcher").hide();
      container.down(".as_i_search").hide();
      break;
    case "boolean" :
      container.down(".as_negator").hide();
      container.down(".as_matcher").hide();
      container.down(".as_search").hide();
      container.down(".as_b_matcher").show();
      container.down(".as_i_matcher").hide();
      container.down(".as_i_search").hide();
      break;
    default :
      alert("oops");
  }
}

function asRemoveCriterion(element) {
  element = $(element).up(".as_criterion");
  element.parentNode.removeChild(element);
}
