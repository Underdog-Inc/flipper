# Manual Test Plan: Flipper UI Expressions

## Test Environment
- **URL**: http://localhost:9999
- **Setup**: Run `bundle exec rackup examples/ui/basic.ru -p 9999`

## Available Properties
- `client_version` (number)
- `client_type` (string)
- `product` (string)
- `identified` (boolean)

---

## Test Cases

### 1. Simple Expression - Add/Create

#### 1.1 Number Property Expression
**Steps:**
1. Navigate to http://localhost:9999
2. Click "Add Feature" or select existing feature
3. In the Expression section, select "Expression" radio button
4. Set Property: `client_version`
5. Set Operator: `>=`
6. Set Value: `2.0`
7. Click "Update Feature"

**Expected Result:**
- Expression saves successfully
- Expression displays as: `client_version >= 2.0`

#### 1.2 String Property Expression
**Steps:**
1. Create/edit a feature
2. Select "Expression" radio button
3. Set Property: `product`
4. Set Operator: `=`
5. Set Value: `premium`
6. Click "Update Feature"

**Expected Result:**
- Expression saves successfully
- Expression displays as: `product = "premium"`

#### 1.3 Boolean Property Expression
**Steps:**
1. Create/edit a feature
2. Select "Expression" radio button
3. Set Property: `identified`
4. Set Operator: `=`
5. Set Value: `true`
6. Click "Update Feature"

**Expected Result:**
- Expression saves successfully
- Expression displays as: `identified = true`

### 2. Simple Expression - Edit

#### 2.1 Modify Existing Expression
**Steps:**
1. Start with existing expression: `client_version >= 2.0`
2. Navigate to feature page
3. Click "Edit" to open expression form
4. **Verify form population**: Confirm dropdowns show correct selected values:
   - Property = "client_version", Operator = "greater than or equal (≥)", Value = "2.0"
5. Change Operator from `>=` to `>`
6. Change Value from `2.0` to `3.0`
7. Click "Update Feature"

**Expected Result:**
- Form displays correct existing values in dropdowns (not placeholders)
- Expression updates successfully
- Expression now displays as: `client_version > 3.0`

### 3. Simple Expression - Remove

#### 3.1 Delete Expression
**Steps:**
1. Start with feature containing an expression
2. Navigate to feature page
3. Select "Disabled" radio button (or another gate type)
4. Click "Update Feature"

**Expected Result:**
- Expression is removed
- Feature no longer uses expression gate

### 4. Complex Expression (Any/OR) - Add/Create

#### 4.1 Multiple Property OR Expression
**Steps:**
1. Create/edit a feature
2. Select "Expression" radio button
3. Select "Any" from expression type dropdown
4. First condition:
   - Property: `product`
   - Operator: `=`
   - Value: `premium`
5. Click "Add Expression" button
6. Second condition:
   - Property: `client_version`
   - Operator: `>=`
   - Value: `3.0`
7. Click "Update Feature"

**Expected Result:**
- Complex expression saves successfully
- Expression displays as: `(product = "premium" OR client_version >= 3.0)`

### 5. Complex Expression (All/AND) - Add/Create

#### 5.1 Multiple Property AND Expression
**Steps:**
1. Create/edit a feature
2. Select "Expression" radio button
3. Select "All" from expression type dropdown
4. First condition:
   - Property: `identified`
   - Operator: `=`
   - Value: `true`
5. Click "Add Expression" button
6. Second condition:
   - Property: `client_type`
   - Operator: `=`
   - Value: `mobile`
7. Click "Update Feature"

**Expected Result:**
- Complex expression saves successfully
- Expression displays as: `(identified = true AND client_type = "mobile")`

### 6. Complex Expression - Edit

#### 6.1 Modify Existing Complex Expression
**Steps:**
1. Start with: `(product = "premium" OR client_version >= 3.0)`
2. Navigate to feature page
3. Click "Edit" to open expression form
4. **Verify form population**: Confirm dropdowns show correct selected values:
   - First row: Property = "product", Operator = "equals (=)", Value = "premium"
   - Second row: Property = "client_version", Operator = "greater than or equal (≥)", Value = "3.0"
5. Change first condition value from `premium` to `enterprise`
6. Change second condition operator from `>=` to `>`
7. Click "Update Feature"

**Expected Result:**
- Form displays correct existing values in dropdowns (not placeholders)
- Expression updates successfully
- Expression displays as: `(product = "enterprise" OR client_version > 3.0)`

#### 6.2 Add Condition to Existing Complex Expression
**Steps:**
1. Start with: `(identified = true AND client_type = "mobile")`
2. Navigate to feature page
3. Click "Edit" to open expression form
4. **Verify form population**: Confirm existing conditions show correct selected values:
   - First row: Property = "identified", Operator = "equals (=)", Value = "true"
   - Second row: Property = "client_type", Operator = "equals (=)", Value = "mobile"
5. Click "Add Expression" button
6. Add third condition:
   - Property: `client_version`
   - Operator: `>=`
   - Value: `2.0`
7. Click "Update Feature"

**Expected Result:**
- Form displays correct existing values in dropdowns (not placeholders)
- Expression updates successfully
- Expression displays as: `(identified = true AND client_type = "mobile" AND client_version >= 2.0)`

#### 6.3 Remove Condition from Complex Expression
**Steps:**
1. Start with 3-condition AND expression from above
2. Navigate to feature page
3. Click "Edit" to open expression form
4. **Verify form population**: Confirm all three conditions show correct selected values
5. Click "Remove" button next to middle condition (`client_type = "mobile"`)
6. Click "Update Feature"

**Expected Result:**
- Form displays correct existing values in dropdowns (not placeholders)
- Expression updates successfully
- Expression displays as: `(identified = true AND client_version >= 2.0)`

### 7. Complex Expression - Remove

#### 7.1 Delete Entire Complex Expression
**Steps:**
1. Start with feature containing complex expression
2. Navigate to feature page
3. Select "Disabled" radio button
4. Click "Update Feature"

**Expected Result:**
- Complex expression is removed
- Feature no longer uses expression gate

### 8. Expression Type Conversion

#### 8.1 Simple to Complex
**Steps:**
1. Start with simple expression: `product = "premium"`
2. Navigate to feature page
3. Click "Edit" to open expression form
4. **Verify form population**: Confirm simple expression shows correct selected values:
   - Property = "product", Operator = "equals (=)", Value = "premium"
5. Change expression type from "Property" to "Any"
6. **Verify conversion**: Original condition should remain with correct dropdown values
7. Add second condition: `client_version >= 2.0`
8. Click "Update Feature"

**Expected Result:**
- Form displays correct existing values in dropdowns during conversion
- Expression converts successfully
- Expression displays as: `(product = "premium" OR client_version >= 2.0)`

#### 8.2 Complex to Simple
**Steps:**
1. Start with complex expression: `(identified = true AND client_type = "mobile")`
2. Navigate to feature page
3. Click "Edit" to open expression form
4. **Verify form population**: Confirm complex expression shows correct selected values:
   - First row: Property = "identified", Operator = "equals (=)", Value = "true"
   - Second row: Property = "client_type", Operator = "equals (=)", Value = "mobile"
5. Change expression type from "All" to "Property"
6. Set single condition: `product = "enterprise"`
7. Click "Update Feature"

**Expected Result:**
- Form displays correct existing values in dropdowns before conversion
- Expression converts successfully
- Expression displays as: `product = "enterprise"`

---

## Test Validation Checklist

For each test case, verify:
- [ ] Expression saves without errors
- [ ] Expression displays correctly in the UI
- [ ] Expression persists after page refresh
- [ ] No JavaScript errors in browser console
- [ ] Form validation works appropriately
- [ ] UI elements (dropdowns, buttons) function correctly
- [ ] **Form population bug check**: When editing existing expressions, verify dropdowns show selected values (not "Select a property..." placeholders)
  - Property dropdowns display the correct selected property name
  - Operator dropdowns display the correct selected operator (e.g., "equals (=)", "greater than (>)")
  - Value fields contain the correct existing values
