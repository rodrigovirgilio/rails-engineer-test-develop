# Quick Guide - Company Search

## Installation

```bash
# 1. Install dependencies
bin/bundle install
yarn install

# 2. Configure database
bin/rails db:create
bin/rails db:migrate

# 3. Populate with sample data (optional)
bin/rails db:seed


# 4. Start server
bin/rails server
```

Access: `http://localhost:3000`

---

## Run Tests

```bash
# All tests
bundle exec rspec

# With documentation
bundle exec rspec --format documentation

# Specific test
bundle exec rspec spec/models/company_spec.rb
```

### Via Web Interface
1. Go to: `http://localhost:3000/admin/companies`
2. Click "Choose File"
3. Select: `config/data/companies.csv`
4. Click "Import Companies"
