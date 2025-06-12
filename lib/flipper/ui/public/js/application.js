// Constants
const SELECTORS = {
  TOOLTIP: '[data-bs-toggle="tooltip"]',
  TOGGLE_TRIGGER: '.js-toggle-trigger',
  TOGGLE_CONTAINER: '.js-toggle-container',
  CONFIRMATION_ELEMENT: '*[data-confirmation-text]',
  EXPRESSION_FORM: 'expression-form',
  EXPRESSION_TYPE_RADIOS: 'input[name="expression_type"]',
  SIMPLE_FORM: 'simple-expression-form',
  COMPLEX_FORM: 'complex-expression-form',
  ADD_EXPRESSION_BTN: 'add-expression-btn',
  EXPRESSION_LIST: 'expression-list',
  EXPRESSION_FORM_DATA: 'expression-form-data',
  EXPRESSION_ROW_TEMPLATE: 'expression-row-template',
  REMOVE_EXPRESSION_BTN: '.remove-expression-btn',
  EXPRESSION_ROWS: '.row',
  EXPRESSION_TYPE_CHECKED: 'input[name="expression_type"]:checked'
};

const CSS_CLASSES = {
  TOGGLE_ON: 'toggle-on',
  HIDDEN: 'd-none'
};

const EXPRESSION_TYPES = {
  PROPERTY: 'property',
  ANY: 'any',
  ALL: 'all'
};

const MESSAGES = {
  ADD_EXPRESSION_TOOLTIP: 'Add Expression is only available for Any/All expression types',
  REMOVE_LAST_EXPRESSION: 'Cannot remove the last expression',
  NO_EXPRESSIONS_ERROR: 'Please add at least one expression.'
};

const TooltipManager = {
  initializeAll() {
    const tooltipElements = document.querySelectorAll(SELECTORS.TOOLTIP);
    tooltipElements.forEach(element => {
      try {
        new bootstrap.Tooltip(element);
      } catch (error) {
        console.warn('Failed to initialize tooltip', error);
      }
    });
  },

  create(element, title) {
    if (!element) return null;

    try {
      this.destroy(element);
      element.setAttribute('data-bs-toggle', 'tooltip');
      element.title = title;
      return new bootstrap.Tooltip(element);
    } catch (error) {
      console.warn('Failed to create tooltip', error);
      return null;
    }
  },

  destroy(element) {
    if (!element) return;

    try {
      const existingTooltip = bootstrap.Tooltip.getInstance(element);
      if (existingTooltip) {
        existingTooltip.dispose();
      }
      element.removeAttribute('data-bs-toggle');
      element.title = '';
    } catch (error) {
      console.warn('Failed to destroy tooltip', error);
    }
  }
};

const ToggleHandler = {
  initializeAll() {
    const triggers = document.querySelectorAll(SELECTORS.TOGGLE_TRIGGER);
    triggers.forEach(trigger => {
      trigger.addEventListener('click', this.handleToggle.bind(this));
    });
  },

  handleToggle(event) {
    try {
      const container = event.target.closest(SELECTORS.TOGGLE_CONTAINER);
      if (container) {
        container.classList.toggle(CSS_CLASSES.TOGGLE_ON);
      }
    } catch (error) {
      console.warn('Failed to handle toggle', error);
    }
  }
};

// Manages confirmation prompts for destructive actions
const ConfirmationHandler = {
  initializeAll() {
    const elements = document.querySelectorAll(SELECTORS.CONFIRMATION_ELEMENT);
    elements.forEach(element => {
      element.addEventListener('click', this.handleConfirmation.bind(this));
    });
  },

  handleConfirmation(event) {
    try {
      const target = event.target;
      const expectedText = target.getAttribute('data-confirmation-text');
      const promptText = target.getAttribute('data-confirmation-prompt');
      
      if (!expectedText || !promptText) return;

      const userInput = prompt(promptText);
      
      if (expectedText !== userInput) {
        event.preventDefault();
      }
    } catch (error) {
      console.warn('Failed to handle confirmation', error);
      event.preventDefault();
    }
  }
};

class ExpressionFormManager {
  constructor() {
    this.form = document.getElementById(SELECTORS.EXPRESSION_FORM);
    this.typeRadios = document.querySelectorAll(SELECTORS.EXPRESSION_TYPE_RADIOS);
    this.simpleForm = document.getElementById(SELECTORS.SIMPLE_FORM);
    this.complexForm = document.getElementById(SELECTORS.COMPLEX_FORM);
    this.addExpressionBtn = document.getElementById(SELECTORS.ADD_EXPRESSION_BTN);
    this.expressionList = document.getElementById(SELECTORS.EXPRESSION_LIST);
    this.expressionCounter = 0;
    
    if (this.form) {
      this.initialize();
    }
  }

  initialize() {
    try {
      this.loadFormData();
      this.initializeFormState();
      this.bindEventListeners();
    } catch (error) {
      console.error('Failed to initialize expression form', error);
    }
  }

  loadFormData() {
    const formDataScript = document.getElementById(SELECTORS.EXPRESSION_FORM_DATA);
    const formData = formDataScript
      ? JSON.parse(formDataScript.textContent)
      : { type: EXPRESSION_TYPES.PROPERTY };

    // Initialize complex expressions if they exist
    if (formData.expressions && formData.expressions.length > 0) {
      formData.expressions.forEach(expr => {
        this.addExpressionRow(expr.property, expr.operator, expr.value);
      });
      this.updateRemoveButtonStates();
    }
  }

  // Initialize form state based on selected radio button
  initializeFormState() {
    const checkedRadio = document.querySelector(SELECTORS.EXPRESSION_TYPE_CHECKED);
    if (checkedRadio) {
      this.handleExpressionTypeChange(checkedRadio.value);
    }
  }

  bindEventListeners() {
    this.typeRadios.forEach(radio => { // Expression type radio buttons
      radio.addEventListener('change', () => {
        this.handleExpressionTypeChange(radio.value);
      });
    });

    if (this.addExpressionBtn) {
      this.addExpressionBtn.addEventListener('click', () => {
        this.addExpressionRow();
      });
    }

    this.form.addEventListener('submit', this.handleFormSubmission.bind(this));
  }

  handleExpressionTypeChange(type) {
    if (type === EXPRESSION_TYPES.PROPERTY) {
      this.showSimpleForm();
      this.showAddExpressionTooltip();
    } else {
      this.showComplexForm();
      this.hideAddExpressionTooltip();
      
      // Add initial expression if none exist
      if (this.expressionList && this.expressionList.children.length === 0) {
        this.addExpressionRow();
      }
    }
  }

  // Show simple form and hide complex form
  showSimpleForm() {
    if (this.simpleForm) this.simpleForm.classList.remove(CSS_CLASSES.HIDDEN);
    if (this.complexForm) this.complexForm.classList.add(CSS_CLASSES.HIDDEN);
  }

  // Show complex form and hide simple form
  showComplexForm() {
    if (this.simpleForm) this.simpleForm.classList.add(CSS_CLASSES.HIDDEN);
    if (this.complexForm) this.complexForm.classList.remove(CSS_CLASSES.HIDDEN);
    this.updateRemoveButtonStates();
  }

  showAddExpressionTooltip() {
    if (!this.addExpressionBtn) return;

    const tooltipWrapper = this.addExpressionBtn.parentElement;
    if (!tooltipWrapper) return;

    this.addExpressionBtn.disabled = true;
    TooltipManager.create(tooltipWrapper, MESSAGES.ADD_EXPRESSION_TOOLTIP);
  }

  hideAddExpressionTooltip() {
    if (!this.addExpressionBtn) return;

    const tooltipWrapper = this.addExpressionBtn.parentElement;
    if (!tooltipWrapper) return;

    this.addExpressionBtn.disabled = false;
    TooltipManager.destroy(tooltipWrapper);
  }

  // Update remove button states based on number of expressions
  updateRemoveButtonStates() {
    if (!this.expressionList) return;

    const expressionRows = this.expressionList.querySelectorAll(SELECTORS.EXPRESSION_ROWS);
    const removeButtons = this.expressionList.querySelectorAll(SELECTORS.REMOVE_EXPRESSION_BTN);

    removeButtons.forEach(btn => {
      if (expressionRows.length <= 1) {
        btn.disabled = true;
        btn.title = MESSAGES.REMOVE_LAST_EXPRESSION;
      } else {
        btn.disabled = false;
        btn.title = '';
      }
    });
  }

  // Add a new expression row (for Any/All expressions)
  addExpressionRow(property = '', operator = '', value = '') {
    if (!this.expressionList) return;

    const template = document.getElementById(SELECTORS.EXPRESSION_ROW_TEMPLATE);
    if (!template) return;

    try {
      const row = template.content.cloneNode(true);
      
      this.updateRowCounters(row); // Update counter in name attributes
      this.setRowValues(row, value); // Set initial values
      this.addRemoveButtonListener(row); // Add remove button listener
      this.expressionList.appendChild(row); // Append to list
      this.setSelectValues(property, operator, this.expressionCounter); // Set select values after DOM insertion
      this.expressionCounter++;
      this.updateRemoveButtonStates();
    } catch (error) {
      console.error('Failed to add expression row', error);
    }
  }

  // Update counter placeholders in row elements
  updateRowCounters(row) {
    const selects = row.querySelectorAll('select');
    const inputs = row.querySelectorAll('input');

    [...selects, ...inputs].forEach(element => {
      if (element.name) {
        element.name = element.name.replace('COUNTER', this.expressionCounter);
      }
    });
  }

  // Set initial values for row inputs
  setRowValues(row, value) {
    const valueInput = row.querySelector('input[name*="value"]');
    if (valueInput) {
      valueInput.value = value || '';
    }
  }

  addRemoveButtonListener(row) {
    const removeBtn = row.querySelector(SELECTORS.REMOVE_EXPRESSION_BTN);
    if (removeBtn) {
      removeBtn.addEventListener('click', () => {
        const rowElement = removeBtn.closest(SELECTORS.EXPRESSION_ROWS);
        if (rowElement) {
          rowElement.remove();
          this.updateRemoveButtonStates();
        }
      });
    }
  }

  setSelectValues(property, operator, counter = this.expressionCounter) {
    // Use setTimeout to ensure DOM is fully updated first
    setTimeout(() => {
      const propertySelect = this.expressionList.querySelector(
        `select[name="complex_expressions[${counter}][property_name]"]`
      );
      const operatorSelect = this.expressionList.querySelector(
        `select[name="complex_expressions[${counter}][operator_class]"]`
      );

      if (propertySelect) {
        propertySelect.value = property || '';
        if (!property) propertySelect.selectedIndex = 0;
      }

      if (operatorSelect) {
        operatorSelect.value = operator || '';
        if (!operator) operatorSelect.selectedIndex = 0;
      }
    }, 0);
  }

  handleFormSubmission(event) {
    try {
      const selectedType = document.querySelector(SELECTORS.EXPRESSION_TYPE_CHECKED);
      
      if (selectedType && (selectedType.value === EXPRESSION_TYPES.ANY || selectedType.value === EXPRESSION_TYPES.ALL)) {
        if (!this.validateExpressions(event)) return;
        this.addHiddenTypeInput(selectedType.value);
      }
    } catch (error) {
      console.error('Failed to handle form submission', error);
      event.preventDefault();
    }
  }

  // Validate that at least one expression exists
  validateExpressions(event) {
    if (!this.expressionList) return false;

    const expressions = this.expressionList.querySelectorAll(SELECTORS.EXPRESSION_ROWS);
    if (expressions.length === 0) {
      event.preventDefault();
      alert(MESSAGES.NO_EXPRESSIONS_ERROR);
      return false;
    }
    return true;
  }

  addHiddenTypeInput(value) {
    const typeInput = document.createElement('input');
    typeInput.type = 'hidden';
    typeInput.name = 'complex_expression_type';
    typeInput.value = value;
    this.form.appendChild(typeInput);
  }
}

// Application Initializer: main entry point for Flipper UI
const FlipperUIApp = {
  initialize() {
    try {
      TooltipManager.initializeAll();
      ToggleHandler.initializeAll();
      ConfirmationHandler.initializeAll();
      
      new ExpressionFormManager();
      
      console.log('Flipper UI Application initialized successfully');
    } catch (error) {
      console.error('Failed to initialize Flipper UI Application', error);
    }
  }
};

document.addEventListener('DOMContentLoaded', () => {
  FlipperUIApp.initialize();
});
