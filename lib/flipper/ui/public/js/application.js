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

  document.querySelectorAll('[data-expression-form]').forEach(function(form) {
    const operatorSelect = form.querySelector('[data-expression-operator]');
    const propertyInput = form.querySelector('[data-expression-property]');
    const valueInput = form.querySelector('[data-expression-value]');

    if (operatorSelect && propertyInput && valueInput) {
      function updateFieldNames() {
        const operator = operatorSelect.value;
        propertyInput.name = `expression[${operator}][][Property][]`;
        valueInput.name = `expression[${operator}][]`;
      }

      updateFieldNames(); // Set correct field names on load.
      operatorSelect.addEventListener('change', updateFieldNames);
    }
  });
});
