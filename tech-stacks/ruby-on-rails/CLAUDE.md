# Development Guide for Claude - Ruby on Rails Stack

## 🎯 Core Philosophy

**TEST-DRIVEN DEVELOPMENT IS NON-NEGOTIABLE.** Every single line of production code must be written in response to a failing test. No exceptions. This is not a suggestion or a preference - it is the fundamental practice that enables all other principles in this document.

### Quick Reference
- **Write tests first** (TDD - Red, Green, Refactor)
- **Test behavior, not implementation**
- **Service objects** for business logic
- **Immutable value objects**
- **Small, focused classes**
- **ActiveRecord validations** always
- **100% behavior coverage** (not just line coverage)
- **Model-first development** with proper validations

## ⚡ Tech Stack Configuration

```yaml
# PROJECT SPECIFIC - Ruby on Rails Stack
Framework: Ruby on Rails 7+
Language: Ruby 3.2+
Testing: RSpec + Capybara + FactoryBot
Database: PostgreSQL 15+
Schema Validation: ActiveModel validations + dry-validation
State Management: Hotwire (Turbo + Stimulus)
Styling: Tailwind CSS + ViewComponent
Package Manager: bundler + yarn/npm
Job Processing: Sidekiq + Redis
Authentication: Devise + Omniauth

Full Stack:
  - Ruby on Rails 7+ (API mode or full stack)
  - Hotwire (Turbo + Stimulus)
  - ViewComponent (component architecture)
  - Tailwind CSS
  - PostgreSQL with ActiveRecord
  - Sidekiq (background jobs)
  - Devise (authentication)
  - ActionCable (WebSockets)
  - ActionMailer (emails)

JavaScript/Frontend:
  - Stimulus controllers
  - Turbo for SPA-like navigation
  - ImportMaps or esbuild/Vite
  - Alpine.js (for interactive components)

Testing:
  - RSpec (unit + integration)
  - Capybara (system tests)
  - FactoryBot (test data)
  - VCR (HTTP mocking)
  - SimpleCov (coverage)

Deployment:
  - Heroku, Render, or AWS
  - Cloudflare CDN
  - Redis for caching/sessions
  - Puma web server
```

## 📁 Repository Structure

```
/
├── app/                   # Rails application directory
│   ├── controllers/      # Request handling
│   ├── models/           # ActiveRecord models
│   ├── views/            # ERB/Haml templates
│   ├── helpers/          # View helpers
│   ├── javascript/       # Stimulus controllers
│   ├── assets/           # CSS, images
│   ├── jobs/             # Background jobs
│   ├── services/         # Business logic services
│   ├── forms/            # Form objects
│   └── components/       # ViewComponents
├── config/               # Rails configuration
│   ├── routes.rb         # Route definitions
│   ├── database.yml      # Database config
│   └── environments/     # Environment configs
├── db/                   # Database files
│   ├── migrate/          # Migration files
│   ├── schema.rb         # Current schema
│   └── seeds.rb          # Seed data
├── lib/                  # Custom libraries
│   └── tasks/            # Rake tasks
├── spec/                 # RSpec tests
│   ├── models/           # Model tests
│   ├── controllers/      # Controller tests
│   ├── services/         # Service tests
│   ├── system/           # System/integration tests
│   ├── factories/        # FactoryBot factories
│   └── support/          # Test helpers
├── docs/                 # Documentation
│   ├── features/         # Feature specs and planning
│   ├── db/              # Database documentation
│   ├── api/             # API documentation
│   ├── ADRs/            # Architectural Decision Records
│   └── audit/           # Code audit reports
├── .claude/             # AI assistant configuration
│   └── commands/        # Custom AI commands
├── Gemfile              # Ruby dependencies
└── Rakefile             # Rake tasks
```

## 🗄️ Database Documentation (CRITICAL FOR AI)

### Overview Documentation Structure

```markdown
# docs/db/00_database_overview.md

## Architecture Philosophy
[Domain-driven design with ActiveRecord as persistence layer]

## Database Technology
- Platform: PostgreSQL 15+
- ORM: ActiveRecord (Rails 7+)
- Migrations: Sequential versioned migrations
- Validations: ActiveModel + custom validators
- Indexing: Database indexes for performance
- Constraints: Database-level constraints + ActiveRecord validations

## Schema Organization Strategy
### Domain Boundaries
Core Domain       → [Primary entities and purpose]
Supporting Domain → [Secondary features]
Analytics Domain  → [Tracking and metrics]

### Cross-Domain Integration Points
- Central entities referenced everywhere
- Data flow patterns between domains

## Table Naming Conventions
- Prefixes: user_*, billing_*, analytics_*
- Relationships: junction tables use both names
- Audit tables: add _history or _audit suffix

## Critical Relationships Map
[Visual or text representation of core entity relationships]

## Query Performance Guidelines
### Hot Paths (Optimize First)
- List frequently accessed queries
- Identify bottlenecks

## Business Context
[What kind of application this supports, tiers, key features]
```

### Migration File Convention

```
/db/migrations/
├── 001_create_users.rb
├── 002_create_profiles.rb
├── 003_create_orders.rb
├── 004_add_indexes_to_orders.rb
├── 005_create_payments.rb
└── 006_add_payment_status_index.rb
```

**Migration Naming Rules:**
- Sequential numbering with Rails timestamps
- Descriptive names: what the migration does
- Use underscores, not camelCase
- Group related changes in single migration when possible
- Never modify existing migrations - always create new ones

### ActiveRecord Patterns

```ruby
# Model with proper validations and associations
class Payment < ApplicationRecord
  VALID_CURRENCIES = %w[USD EUR GBP CAD].freeze
  VALID_STATUSES = %w[pending processing completed failed refunded].freeze
  
  belongs_to :user
  belongs_to :order
  has_many :payment_logs, dependent: :destroy
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, inclusion: { in: VALID_CURRENCIES }
  validates :status, inclusion: { in: VALID_STATUSES }
  validates :gateway_transaction_id, presence: true, uniqueness: true
  
  enum status: {
    pending: 0,
    processing: 1,
    completed: 2,
    failed: 3,
    refunded: 4
  }
  
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :successful, -> { where(status: [:completed, :refunded]) }
  
  def total_with_currency
    "#{currency} #{amount}"
  end
  
  def refundable?
    completed? && created_at > 30.days.ago
  end
end

# Migration with proper indexes and constraints
class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments, id: :uuid do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, null: false, limit: 3
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.string :gateway_transaction_id, null: false
      t.integer :status, default: 0, null: false
      t.text :gateway_response
      t.timestamp :processed_at
      
      t.timestamps
    end
    
    add_index :payments, [:user_id, :created_at]
    add_index :payments, :gateway_transaction_id, unique: true
    add_index :payments, :status
    add_index :payments, [:order_id, :status]
    
    add_check_constraint :payments, 'amount > 0', name: 'payments_amount_positive'
    add_check_constraint :payments, "currency IN ('USD', 'EUR', 'GBP', 'CAD')", name: 'payments_currency_valid'
  end
end
```

## 🔄 Development Workflow

### Test-Driven Development Cycle

```ruby
# Step 1: RED - Write a failing test (spec/services/payment_processor_spec.rb)
RSpec.describe PaymentProcessor do
  describe '#process' do
    it 'processes valid payment successfully' do
      payment = build(:payment, amount: 100.00)
      processor = PaymentProcessor.new
      
      result = processor.process(payment)
      
      expect(result).to be_success
      expect(result.processed_payment.status).to eq('completed')
    end
  end
end

# Step 2: GREEN - Minimal implementation (app/services/payment_processor.rb)
class PaymentProcessor
  Result = Data.define(:success?, :processed_payment, :error_message)
  
  def process(payment)
    return Result.new(false, nil, 'Payment is invalid') unless payment.valid?
    
    begin
      payment.update!(status: 'completed', processed_at: Time.current)
      Result.new(true, payment, nil)
    rescue StandardError => e
      Result.new(false, nil, e.message)
    end
  end
end

# Step 3: REFACTOR - Assess improvements
# Extract result object, add error handling, etc.
```

### Feature Development Process

1. **Plan**: Define feature requirements and acceptance criteria
2. **Test**: Write failing tests for each acceptance criterion
3. **Implement**: Write minimal code to pass tests
4. **Refactor**: Assess and improve code quality
5. **Document**: Update relevant documentation
6. **Commit**: Use conventional commits (NO AI signatures)

### Commit Standards

```bash
# ✅ Good commits
git commit -m "feat: add payment processing service"
git commit -m "fix: correct currency validation in payments"
git commit -m "refactor: extract payment validation logic"
git commit -m "test: add edge cases for payment processing"

# ❌ Never include
# - "Generated with Claude"
# - "AI-assisted"
# - Any mention of AI/Claude
```

## 📐 Architecture Principles

### Model-First Development

```ruby
# 1. Define ActiveRecord model first (app/models/payment.rb)
class Payment < ApplicationRecord
  VALID_CURRENCIES = %w[USD EUR GBP].freeze
  
  belongs_to :customer
  belongs_to :card
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, inclusion: { in: VALID_CURRENCIES }
  validates :customer_id, :card_id, presence: true
  
  enum status: { pending: 0, processed: 1, failed: 2, refunded: 3 }
  
  scope :recent, -> { order(created_at: :desc) }
  scope :for_customer, ->(customer) { where(customer: customer) }
end

# 2. Database migration (db/migrate/xxx_create_payments.rb)
class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments, id: :uuid do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, null: false
      t.references :customer, null: false, foreign_key: true, type: :uuid
      t.references :card, null: false, foreign_key: true, type: :uuid
      t.integer :status, default: 0, null: false
      
      t.timestamps
    end
    
    add_index :payments, [:customer_id, :created_at]
    add_index :payments, :status
  end
end

# 3. Strong parameters in controller
class PaymentsController < ApplicationController
  private
  
  def payment_params
    params.require(:payment).permit(:amount, :currency, :customer_id, :card_id)
  end
end

# 4. CRITICAL: Use FactoryBot for consistent test data
# spec/factories/payments.rb
FactoryBot.define do
  factory :payment do
    amount { 100.00 }
    currency { 'USD' }
    association :customer
    association :card
    status { :pending }
  end
end
```

### Rails Patterns and Principles

```ruby
# ✅ Good: Service objects for business logic
class UserUpdateService
  def initialize(user)
    @user = user
  end
  
  def call(attributes)
    @user.assign_attributes(attributes)
    
    if @user.save
      UserMailer.profile_updated(@user).deliver_later
      Result.success(@user)
    else
      Result.failure(@user.errors)
    end
  end
  
  private
  
  attr_reader :user
end

# ✅ Good: Form objects for complex forms
class UserRegistrationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  
  attribute :email, :string
  attribute :password, :string
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :terms_accepted, :boolean
  
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }
  validates :first_name, :last_name, presence: true
  validates :terms_accepted, acceptance: true
  
  def save
    return false unless valid?
    
    ActiveRecord::Base.transaction do
      user = User.create!(user_attributes)
      UserProfile.create!(profile_attributes.merge(user: user))
      user
    end
  end
  
  private
  
  def user_attributes
    { email: email, password: password }
  end
  
  def profile_attributes
    { first_name: first_name, last_name: last_name }
  end
end

# ❌ Avoid: Fat controllers, put logic in services/models
class UsersController < ApplicationController
  def create
    # Don't put complex logic here
  end
end
```

### Keyword Arguments Pattern

```ruby
# ✅ Default pattern for service methods
class OrderProcessor
  def process(order:, shipping_options:, payment_options:, promotions: {})
    validate_order!(order)
    
    result = OrderProcessingResult.new
    result.order = order
    result.shipping_cost = calculate_shipping(order, shipping_options)
    result.payment_result = process_payment(order, payment_options)
    result.applied_promotions = apply_promotions(order, promotions)
    
    result
  end
  
  private
  
  def validate_order!(order)
    raise OrderValidationError, 'Order cannot be empty' if order.items.empty?
    raise OrderValidationError, 'Invalid order status' unless order.pending?
  end
  
  def calculate_shipping(order, options)
    ShippingCalculator.new(order, **options).calculate
  end
end

# ✅ Usage with keyword arguments
result = OrderProcessor.new.process(
  order: current_order,
  shipping_options: { method: 'express', address: shipping_address },
  payment_options: { card: payment_card, billing_address: billing_address },
  promotions: { coupon_code: params[:coupon] }
)

# ✅ Simple methods can use positional arguments
def double(number)
  number * 2
end
```

## 🧪 Testing Guidelines

### Behavior-Driven Testing

```ruby
# ✅ Test behavior through public API
RSpec.describe OrderProcessor do
  describe '#process' do
    it 'applies free shipping for orders over $50' do
      order = create(:order, :with_items, subtotal: 60.00)
      processor = OrderProcessor.new
      
      result = processor.process(
        order: order,
        shipping_options: { method: 'standard' },
        payment_options: { card: create(:card) }
      )
      
      expect(result.shipping_cost).to eq(0)
    end
    
    context 'when order total is under $50' do
      it 'applies standard shipping cost' do
        order = create(:order, :with_items, subtotal: 30.00)
        processor = OrderProcessor.new
        
        result = processor.process(
          order: order,
          shipping_options: { method: 'standard' },
          payment_options: { card: create(:card) }
        )
        
        expect(result.shipping_cost).to eq(5.99)
      end
    end
  end
end

# ❌ Don't test implementation details
it 'calls ShippingCalculator' do
  # This tests HOW not WHAT - avoid this
end

# ✅ System/integration tests with Capybara
RSpec.describe 'Order checkout process', type: :system do
  it 'completes order successfully' do
    user = create(:user)
    product = create(:product, price: 25.00)
    
    sign_in user
    visit product_path(product)
    click_button 'Add to Cart'
    click_link 'Checkout'
    
    fill_in 'Card Number', with: '4111111111111111'
    fill_in 'Expiry', with: '12/25'
    fill_in 'CVV', with: '123'
    click_button 'Complete Order'
    
    expect(page).to have_content('Order completed successfully')
    expect(user.orders.count).to eq(1)
  end
end
```

### FactoryBot Patterns

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    password { 'password123' }
    confirmed_at { Time.current }
    
    trait :admin do
      role { :admin }
    end
    
    trait :unconfirmed do
      confirmed_at { nil }
    end
    
    trait :with_profile do
      after(:create) do |user|
        create(:user_profile, user: user)
      end
    end
  end
end

# spec/factories/orders.rb
FactoryBot.define do
  factory :order do
    association :user
    status { :pending }
    
    trait :with_items do
      transient do
        items_count { 2 }
        subtotal { nil }
      end
      
      after(:create) do |order, evaluator|
        if evaluator.subtotal
          # Create items that sum to the specified subtotal
          item_price = evaluator.subtotal / evaluator.items_count
          create_list(:order_item, evaluator.items_count, 
                     order: order, price: item_price)
        else
          create_list(:order_item, evaluator.items_count, order: order)
        end
        
        order.reload # Refresh associations
      end
    end
    
    trait :completed do
      status { :completed }
      completed_at { Time.current }
    end
  end
end

# Usage in tests
let(:user) { create(:user) }
let(:admin_user) { create(:user, :admin) }
let(:order_with_items) { create(:order, :with_items, items_count: 3, user: user) }
let(:expensive_order) { create(:order, :with_items, subtotal: 100.00) }
```

## 🔧 Ruby and Rails Configuration

### Gemfile Structure

```ruby
# Gemfile
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

gem 'rails', '~> 7.0.0'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'redis', '~> 4.0'
gem 'sidekiq', '~> 7.0'
gem 'devise'
gem 'omniauth'
gem 'omniauth-rails_csrf_protection'
gem 'image_processing', '~> 1.2'
gem 'view_component'
gem 'dry-validation'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'sassc-rails'
gem 'tailwindcss-rails'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'dotenv-rails'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webmock'
  gem 'vcr'
  gem 'simplecov', require: false
  gem 'shoulda-matchers'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end
```

### RuboCop Configuration

```yaml
# .rubocop.yml
require:
  - rubocop-rails
  - rubocop-rspec

AllCops:
  TargetRubyVersion: 3.2
  NewCops: enable
  Exclude:
    - 'db/schema.rb'
    - 'db/migrate/*.rb'
    - 'bin/*'
    - 'vendor/**/*'
    - 'node_modules/**/*'

Style/Documentation:
  Enabled: false  # We prefer clear, self-documenting code

Metrics/BlockLength:
  Exclude:
    - 'spec/**/*.rb'
    - 'config/routes.rb'
    - 'db/seeds.rb'

Layout/LineLength:
  Max: 120
  AllowedPatterns: ['(\A|\s)#']
```

### Ruby Style Guidelines

- **Explicit return** - Only when needed for clarity
- **Guard clauses** - Use early returns to reduce nesting
- **Keyword arguments** - For methods with multiple parameters
- **Constants** - Use SCREAMING_SNAKE_CASE
- **Value objects** - Create classes for domain concepts

```ruby
# ✅ Good: Value objects for domain concepts
class Money
  include Comparable
  
  attr_reader :amount, :currency
  
  def initialize(amount, currency = 'USD')
    @amount = BigDecimal(amount.to_s)
    @currency = currency.to_s.upcase
  end
  
  def +(other)
    raise ArgumentError, 'Currency mismatch' unless currency == other.currency
    Money.new(amount + other.amount, currency)
  end
  
  def <=>(other)
    return nil unless currency == other.currency
    amount <=> other.amount
  end
  
  def to_s
    "#{currency} #{amount}"
  end
end

# ✅ Good: Service objects with clear interfaces
class PaymentProcessingService
  Result = Data.define(:success?, :payment, :error_message)
  
  def self.call(**args)
    new.call(**args)
  end
  
  def call(payment:, card:, amount:)
    return Result.new(false, nil, 'Invalid amount') if amount <= 0
    
    # Process payment logic here
    processed_payment = Payment.create!(
      card: card,
      amount: amount,
      status: 'processed'
    )
    
    Result.new(true, processed_payment, nil)
  rescue StandardError => e
    Result.new(false, nil, e.message)
  end
end
```

## 🤖 AI Assistant Collaboration

### Session Management

```markdown
## Starting a Session
1. Use TodoRead to check current tasks
2. Review recent commits for context
3. Verify working directory state
4. Ask about session goals

## During Development
- Work on one task at a time
- Mark todos as in_progress before starting
- Run tests after each implementation
- Commit working code before refactoring
- Update todos in real-time
```

### AI Safety Guidelines

```markdown
✅ AI CAN safely:
- Implement service objects with clear specs
- Write tests for defined behaviors
- Refactor with passing tests
- Update documentation
- Create model validations

⚠️ AI SHOULD confirm before:
- Modifying authentication/authorization
- Changing database schemas/migrations
- Updating critical business logic
- Installing new dependencies
- Modifying configuration files

❌ AI MUST NOT:
- Store secrets in code
- Remove from .env files
- Push to remote repositories
- Make architectural decisions alone
- Create files unless necessary
```

### Code Boundaries for AI

```ruby
# Use clear section markers for complex edits
class PaymentProcessor
  def process(payment)
    # === VALIDATION SECTION START ===
    validation_result = validate_payment(payment)
    return validation_result unless validation_result.success?
    # === VALIDATION SECTION END ===
    
    # === PROCESSING SECTION START ===
    processed_payment = execute_payment(payment)
    # === PROCESSING SECTION END ===
    
    # === NOTIFICATION SECTION START ===
    notify_payment_processed(processed_payment)
    # === NOTIFICATION SECTION END ===
    
    Result.success(processed_payment)
  end
  
  private
  
  def validate_payment(payment)
    return Result.failure('Payment is required') if payment.nil?
    return Result.failure('Invalid amount') if payment.amount <= 0
    
    Result.success(payment)
  end
  
  def execute_payment(payment)
    # Implementation here
  end
  
  def notify_payment_processed(payment)
    PaymentProcessedNotifier.call(payment)
  end
end
```

## 🚀 Development Practices

### Code Style

1. **Self-documenting code** - No comments
2. **Early returns** - No nested conditionals
3. **Small classes** - Single responsibility
4. **Descriptive names** - Variables and methods should explain themselves

### Error Handling

```ruby
# Use Result objects for expected errors
class Result
  attr_reader :data, :error
  
  def initialize(success, data = nil, error = nil)
    @success = success
    @data = data
    @error = error
  end
  
  def success?
    @success
  end
  
  def failure?
    !@success
  end
  
  def self.success(data = nil)
    new(true, data)
  end
  
  def self.failure(error)
    new(false, nil, error)
  end
end

# Custom error classes for domain-specific errors
class PaymentError < StandardError; end
class InsufficientFundsError < PaymentError; end
class InvalidCardError < PaymentError; end

# Service with proper error handling
class PaymentService
  def process(payment_params)
    payment = Payment.new(payment_params)
    
    return Result.failure(payment.errors.full_messages) unless payment.valid?
    
    begin
      gateway_response = payment_gateway.charge(payment)
      payment.update!(status: 'processed', gateway_id: gateway_response.id)
      Result.success(payment)
    rescue InsufficientFundsError => e
      payment.update!(status: 'failed', error_message: e.message)
      Result.failure('Insufficient funds')
    rescue StandardError => e
      Rails.logger.error "Payment processing failed: #{e.message}"
      Result.failure('Payment processing failed')
    end
  end
end

# Use exceptions for unexpected/system errors
class DatabaseConnectionError < StandardError; end

def critical_operation
  raise DatabaseConnectionError, 'Cannot connect to database' unless database_available?
end
```

### Refactoring Checklist

Before marking refactoring complete:
- [ ] Code improves readability (if not, don't refactor)
- [ ] All tests pass without modification
- [ ] No new public APIs added
- [ ] RuboCop passes
- [ ] Committed separately from features

## ⚠️ Critical Instructions

### NEVER
- Skip writing tests first (TDD is mandatory)
- Put business logic in controllers (use services/models)
- Use `rescue Exception` (use specific error classes)
- Include AI/Claude mentions in commits
- Push to remote unless explicitly asked
- Expose sensitive data in logs or responses
- Create files unless absolutely necessary
- Create documentation unless requested
- Use `find` without error handling (use `find_by` or `find!`)
- Skip ActiveRecord validations

### ALWAYS
- Write tests first (TDD with RSpec)
- Use strong parameters in controllers
- Validate data at model and service layers
- Prefer editing existing files
- Run tests after implementation (`bundle exec rspec`)
- Use database indexes for query performance
- Use conventional commits (feat/fix/refactor)
- Keep service objects focused on single responsibility
- Use keyword arguments for methods with multiple params
- Handle errors explicitly (Result objects or proper exceptions)
- Use ActiveRecord scopes for reusable queries
- Follow Rails conventions and naming

## 📋 Custom Commands

### /audit
Performs comprehensive codebase analysis across:
- Code quality and duplication
- Security vulnerabilities
- Database optimization
- Documentation gaps
- Dependency issues

### /plan [feature-name]
Creates detailed feature specification including:
- User stories and acceptance criteria
- Technical approach
- Database changes
- API endpoints
- Testing strategy

### /add-feature [feature-name]
Adds feature to planning queue with strategic questions for consideration

## 📚 Resources

- [Rails Guides](https://guides.rubyonrails.org/)
- [RSpec Documentation](https://rspec.info/documentation/)
- [Ruby Style Guide](https://rubystyle.guide/)
- [Rails Style Guide](https://rails.rubystyle.guide/)
- [FactoryBot Documentation](https://github.com/thoughtbot/factory_bot)
- [Capybara Documentation](https://github.com/teamcapybara/capybara)
- [Sidekiq Documentation](https://github.com/mperham/sidekiq)
- [Devise Documentation](https://github.com/heartcombo/devise)
- Project-specific ADRs in `/docs/ADRs/`

---

**Remember**: The key is writing clean, testable, service-oriented code that evolves through small, safe increments. Every change should be driven by a test that describes the desired behavior. When in doubt, favor Rails conventions and simplicity over cleverness.