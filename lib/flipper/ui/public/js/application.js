document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(function(el) {
    new bootstrap.Tooltip(el)
  })

  document.querySelectorAll(".js-toggle-trigger").forEach(function (trigger) {
    trigger.addEventListener("click", function () {
      var container = this.closest(".js-toggle-container");
      container.classList.toggle("toggle-on");
    });
  });

  document.querySelectorAll("*[data-confirmation-text]").forEach(function (element) {
    element.addEventListener("click", function (e) {
      var expected = e.target.getAttribute("data-confirmation-text");
      var actual = prompt(e.target.getAttribute("data-confirmation-prompt"));

      if (expected !== actual) {
        e.preventDefault();
      }
    });
  });

  // Expression form handling
  var expressionForm = document.getElementById("expression-form");
  if (expressionForm) {
    var typeRadios = document.querySelectorAll('input[name="expression_type"]');
    var simpleForm = document.getElementById("simple-expression-form");
    var complexForm = document.getElementById("complex-expression-form");
    var addExpressionBtn = document.getElementById("add-expression-btn");
    var expressionList = document.getElementById("expression-list");
    var expressionCounter = 0;

    // Helper functions to manage tooltip state for add expression button
    function showAddExpressionTooltip() {
      if (!addExpressionBtn) return;
      
      var tooltipWrapper = addExpressionBtn.parentElement;
      if (!tooltipWrapper) return;

      // Destroy existing tooltip instance
      var existingTooltip = bootstrap.Tooltip.getInstance(tooltipWrapper);
      if (existingTooltip) {
        existingTooltip.dispose();
      }

      // Button is disabled - show tooltip
      addExpressionBtn.disabled = true;
      addExpressionBtn.title = "Add Expression is only available for Any/All expression types";
      tooltipWrapper.setAttribute('data-bs-toggle', 'tooltip');
      new bootstrap.Tooltip(tooltipWrapper);
    }

    function hideAddExpressionTooltip() {
      if (!addExpressionBtn) return;
      
      var tooltipWrapper = addExpressionBtn.parentElement;
      if (!tooltipWrapper) return;

      // Destroy existing tooltip instance
      var existingTooltip = bootstrap.Tooltip.getInstance(tooltipWrapper);
      if (existingTooltip) {
        existingTooltip.dispose();
      }

      // Button is enabled - remove tooltip
      addExpressionBtn.disabled = false;
      addExpressionBtn.title = "";
      tooltipWrapper.removeAttribute('data-bs-toggle');
    }

    // Update remove button states based on number of expressions
    function updateRemoveButtonStates() {
      var expressionRows = expressionList.querySelectorAll(".row");
      var removeButtons = expressionList.querySelectorAll(".remove-expression-btn");

      removeButtons.forEach(function(btn) {
        if (expressionRows.length <= 1) {
          btn.disabled = true;
          btn.title = "Cannot remove the last expression";
        } else {
          btn.disabled = false;
          btn.title = "";
        }
      });
    }

    // Initialize form with existing data
    var formDataScript = document.getElementById("expression-form-data");
    var formData = formDataScript ? JSON.parse(formDataScript.textContent) : { type: "property" };
    
    // Initialize complex expressions if they exist
    if (formData.expressions && formData.expressions.length > 0) {
      formData.expressions.forEach(function(expr) {
        addExpressionRow(expr.property, expr.operator, expr.value);
      });
      updateRemoveButtonStates();
    }

    // Initialize form state based on checked radio button
    var checkedRadio = document.querySelector('input[name="expression_type"]:checked');
    if (checkedRadio) {
      if (checkedRadio.value === "property") {
        simpleForm.classList.remove("d-none");
        complexForm.classList.add("d-none");
        showAddExpressionTooltip(); // Button disabled, show tooltip
      } else {
        simpleForm.classList.add("d-none");
        complexForm.classList.remove("d-none");
        hideAddExpressionTooltip(); // Button enabled, hide tooltip
        // Update button states if there are existing expressions
        updateRemoveButtonStates();
      }
    }

    // Handle expression type changes
    typeRadios.forEach(function(radio) {
      radio.addEventListener("change", function() {
        if (this.value === "property") {
          simpleForm.classList.remove("d-none");
          complexForm.classList.add("d-none");
          showAddExpressionTooltip(); // Button disabled, show tooltip
        } else {
          simpleForm.classList.add("d-none");
          complexForm.classList.remove("d-none");
          hideAddExpressionTooltip(); // Button enabled, hide tooltip
          // Add initial expression if none exist
          if (expressionList.children.length === 0) {
            addExpressionRow();
          }
        }
      });
    });

    // Add expression row for complex forms
    function addExpressionRow(property, operator, value) {
      var template = document.getElementById("expression-row-template");
      var row = template.content.cloneNode(true);

      // Update the counter in name attributes
      var selects = row.querySelectorAll("select");
      var inputs = row.querySelectorAll("input");

      selects.forEach(function(select) {
        select.name = select.name.replace("COUNTER", expressionCounter);
      });

      inputs.forEach(function(input) {
        input.name = input.name.replace("COUNTER", expressionCounter);
      });

      // Set initial values before adding to DOM
      var propertySelect = row.querySelector('select[name*="property_name"]');
      var operatorSelect = row.querySelector('select[name*="operator_class"]');
      var valueInput = row.querySelector('input[name*="value"]');
      
      if (valueInput) {
        valueInput.value = value || '';
      }

      // Add event listener to remove button
      var removeBtn = row.querySelector(".remove-expression-btn");
      removeBtn.addEventListener("click", function() {
        removeBtn.closest(".row").remove();
        updateRemoveButtonStates();
      });

      expressionList.appendChild(row);
      
      // Set select values after adding to DOM to ensure proper selection
      // Query the elements from the DOM after they've been added
      setTimeout(function() {
        var addedPropertySelect = expressionList.querySelector('select[name="complex_expressions[' + expressionCounter + '][property_name]"]');
        var addedOperatorSelect = expressionList.querySelector('select[name="complex_expressions[' + expressionCounter + '][operator_class]"]');
        
        if (addedPropertySelect) {
          if (property) {
            addedPropertySelect.value = property;
          } else {
            // Ensure the first option (placeholder) is selected when no property is provided
            addedPropertySelect.value = '';
            addedPropertySelect.selectedIndex = 0;
          }
        }
        
        if (addedOperatorSelect) {
          if (operator) {
            addedOperatorSelect.value = operator;
          } else {
            // Ensure the first option (placeholder) is selected when no operator is provided
            addedOperatorSelect.value = '';
            addedOperatorSelect.selectedIndex = 0;
          }
        }
      }, 0);
      
      expressionCounter++;
      updateRemoveButtonStates();
    }

    // Add expression button click handler
    if (addExpressionBtn) {
      addExpressionBtn.addEventListener("click", addExpressionRow);
    }

    // Form submission handling for complex expressions
    expressionForm.addEventListener("submit", function(e) {
      var selectedType = document.querySelector('input[name="expression_type"]:checked');
      if (selectedType && (selectedType.value === "any" || selectedType.value === "all")) {
        // Validate at least one expression exists
        var expressions = expressionList.querySelectorAll(".row");
        if (expressions.length === 0) {
          e.preventDefault();
          alert("Please add at least one expression.");
          return;
        }

        // Add hidden input for expression type
        var typeInput = document.createElement("input");
        typeInput.type = "hidden";
        typeInput.name = "complex_expression_type";
        typeInput.value = selectedType.value;
        expressionForm.appendChild(typeInput);
      }
    });
  }
});
