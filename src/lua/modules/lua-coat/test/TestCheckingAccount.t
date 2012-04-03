#!/usr/bin/env lua

require 'CheckingAccount'
require 'Test.More'

plan(20)

if not require_ok 'CheckingAccount' then
    skip_rest "no lib"
    os.exit()
end

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o CheckingAccount.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

savings_account = BankAccount{ balance = 250 }
ok( savings_account:isa 'BankAccount', "BankAccount" )
is( savings_account.balance, 250 )
savings_account:withdraw( 50 )
is( savings_account.balance, 200 )
savings_account:deposit( 150 )
is( savings_account.balance, 350 )

savings_account = BankAccount{ balance = 350 }
checking_account = CheckingAccount{ balance = 100, overdraft_account = savings_account }
ok( checking_account:isa 'CheckingAccount', "CheckingAccount" )
ok( checking_account:isa 'BankAccount' )
is( checking_account.overdraft_account, savings_account )
is( checking_account.balance, 100 )
checking_account:withdraw(50)
is( checking_account.balance, 50 )
is( savings_account.balance, 350 )
checking_account:withdraw(200)
is( checking_account.balance, 0 )
is( savings_account.balance, 200 )

checking_account = CheckingAccount{ balance = 100 }
ok( checking_account:isa 'CheckingAccount', "CheckingAccountSimple" )
ok( checking_account:isa 'BankAccount' )
is( checking_account.overdraft_account, nil )
is( checking_account.balance, 100 )
is( checking_account.balance, 100 )
checking_account:withdraw(50)
is( checking_account.balance, 50 )
error_like([[checking_account:withdraw(200)]],
           "Account overdrawn")

