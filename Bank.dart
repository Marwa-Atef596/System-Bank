import 'dart:io';

class Account {
  int accountNumber;
  String ownerName;
  double balance;

  Account(this.accountNumber, this.ownerName, this.balance);
}

abstract class Transaction {
  int? transactionId;

  double execute(Account account);
}

class Deposit extends Transaction {
  double amount;

  Deposit(this.amount);

  @override
  double execute(Account account) {
    return account.balance += amount;
  }
}

class Withdraw extends Transaction {
  double amount;

  Withdraw(this.amount);

  @override
  double execute(Account account) {
    return account.balance -= amount;
  }
}

class BalanceInquiry extends Transaction {
  String currencyType;

  BalanceInquiry(this.currencyType);

  @override
  double execute(Account account) {
    if (currencyType == 'U') {
      print('Current balance in USD: \$${account.balance}');
    } else if (currencyType == 'E') {
      print('Current balance in Euro: €${account.balance}');
    } else {
      print('Invalid currency type');
    }
    return account.balance;
  }
}

class Rollback {
  double? cancelTransaction(Account account) {
    return null;
  }
}

class RollbackDeposit implements Rollback {
  double amount;

  RollbackDeposit(this.amount);

  @override
  double cancelTransaction(Account account) {
    return account.balance -= amount;
  }
}

class RollbackWithdraw implements Rollback {
  double amount;

  RollbackWithdraw(this.amount);

  @override
  double cancelTransaction(Account account) {
    return account.balance += amount;
  }
}

void main() {
  Account? account;
  Transaction? t;
  Rollback? r;

  while (true) {
    print('1. Enter account details');
    print('2. Deposit');
    print('3. Withdraw');
    print('4. Show current balance');
    print('5. Cancel last transaction');
    print('6. Exit');
    stdout.write('Enter your choice: ');
    int num = int.parse(stdin.readLineSync()!);

    if (num == 1) {
      stdout.write('Enter your account number: ');
      int accountNumber = int.parse(stdin.readLineSync()!);
      stdout.write('Enter owner name: ');
      var ownerName = stdin.readLineSync()!;
      stdout.write('Enter balance: ');
      double balance = double.parse(stdin.readLineSync()!);
      account = Account(accountNumber, ownerName, balance);
      print('Account details saved');
    } else if (num == 2) {
      if (account == null) {
        print('Please enter account details');
        continue;
      }
      stdout.write('Enter amount to deposit: ');
      double amount = double.parse(stdin.readLineSync()!);
      Deposit deposit = Deposit(amount);
      var B = deposit.execute(account);
      t = deposit;
      print('New balance: \$${B}');
    } else if (num == 3) {
      if (account == null) {
        print('Please enter account details');
        continue;
      }
      stdout.write('Enter amount to withdraw: ');
      double amount = double.parse(stdin.readLineSync()!);
      if (amount > account.balance) {
        print('Error');
        continue;
      }
      Withdraw withdraw = Withdraw(amount);
      var B = withdraw.execute(account);
      t = withdraw;
      print('New balance: \$${B}');
    } else if (num == 4) {
      if (account == null) {
        print('Please enter account details');
        continue;
      }
      stdout.write('Enter currency type (U for USD, E for Euro): ');
      var currencyType = stdin.readLineSync();
      BalanceInquiry balanceInquiry = BalanceInquiry(currencyType!);
      balanceInquiry.execute(account);
    } else if (num == 5) {
      if (t == null) {
        print('No transaction to cancel');
        continue;
      }
      if (t is Deposit) {
        Rollback rollback = RollbackDeposit(t.amount);
        var B = rollback.cancelTransaction(account!);
        r = rollback;
        t = null;
        print('Transaction cancelled & balance: \$${B}');
      } else if (t is Withdraw) {
        Rollback rollback = RollbackWithdraw(t.amount);
        var B = rollback.cancelTransaction(account!);
        r = rollback;
        t = null;
        print('Transaction cancelled & balance: \$${B}');
      }
    } else if (num == 6) {
      break;
    } else {
      print('Invalid choice');
    }
  }
}
