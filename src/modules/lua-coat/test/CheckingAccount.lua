
require 'Coat'

class 'BankAccount'

has.balance = { isa = 'number', is = 'rw', default = 0 }

function method:deposit (amount)
    self.balance = self.balance + amount
end

function method:withdraw (amount)
    local current_balance = self.balance
    if current_balance < amount then
        error "Account overdrawn"
    end
    self.balance = current_balance - amount
end

class 'CheckingAccount'
extends 'BankAccount'

has.overdraft_account = { isa = 'BankAccount', is = 'rw' }

function before:withdraw (amount)
    local overdraft_amount = amount - self.balance
    if overdraft_amount > 0 then
        local overdraft_account = self.overdraft_account
        if overdraft_account then
            overdraft_account:withdraw(overdraft_amount)
            self:deposit(overdraft_amount)
        end
    end
end

