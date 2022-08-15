# Mocker Mocking Framework
Mocker is a mocking framework that helps you to create mocks for APEX classes and interfaces.
It is super easy to use and helpful for unit testing.

## How To Create Unit Tests For Your Application

Unit testing is a methodology used to test individual units of source code in an application. In OOP those units are classes and their public methods.

Classes can have dependencies; in other words, classes can call other classes. To create unit tests, you must replace these dependencies with some kind of code you have control over. Those replacement classes are commonly called mocks.

```
         Runtime dependencies                          Test dependencies
             -------------                               -------------
            |   MyClass   |                             |   MyClass   |
             -------------                               -------------
              /         \               ====>             /         \
             /           \                               /           \
   -------------        -------------          -------------        -------------
  | Dependency1 |      | Dependency2 |        |    Mock1    |      |    Mock2    |
   -------------        -------------          -------------        -------------

```

## Preparing Your Classes For Unit Testing

To use the mocked classes created by the Mocker Framework is necessary to adapt your target classes to receive these mock instances. There are several ways to do it. Here are some suggestions.

### 1 - Passing Dependencies Through The Class Constructor

The tested class dependencies will be received through the class constructor.
We usually use this approach with some Dependency Injection framework.

```java
public class MyService {

    private IMySelector mySelector;

    public MyService(IMySelector mySelector) {
        this.mySelector = mySelector;
    }

    public void doSomething() {
        // ....
        List<Account> account = mySelector.getAccounts();
        // ....
    }
}
```

### 2 - Using @TestVisible Private Fields

The class dependencies will be created using private fields. Those dependencies can be replaced by mock instances during the unit testing.

```java
public class MyService {

    @TestVisible
    private IMySelector mySelector = new MySelector();

    public void doSomething() {
        // ....
        List<Account> account = mySelector.getAccounts();
        // ....
    }
}
```

### 3 - Using An IOC Container

The class dependencies will be received through an IOC container. During the testing phase we can instruct the IOC container to return the mock instance instead of the real implementation.

```java
public class MyService {

    public void doSomething() {
        // ....
        IMySelector mySelector = Container.instance.get(IMySelector.class);
        List<Account> account = mySelector.getAccounts();
        // ....
    }
}
```

## Using The Mocker Framework To Mock Your Dependencies

### Mocker Framework Phases

The Mocker Framework works in three phases: Stubbing, Executing (Replaying) and Asserting.

* _Stubbing_ phase: The Mocker Framework will record the mock actions and expected behaviours;
* _Executing_ phase: It will replay the recorded actions such as mocked return values or exceptions, and it will record any action executed over the mock instance;
* _Asserting_ phase: It will assert if the mock has executed the expected behaviours.

### Mocking Methods Return Value

Given the following dependency class...

```java
public class MyDependency {

    public Contact getContactByEmail(String email) {
        return [SELECT Id, NAME FROM Contact WHERE Email = :email LIMIT 1];
    }

    public void insertContact(Contact contact) {
        insert contact;
    }
}
```

#### Mocking The Method Return For Specific Parameter Values

You can mock _getContactByEmail_ return value for specific email values...

```java
@IsTest
public class MyTest {
    @IsTest
    static void myTestExample01() {
        Mocker mocker = Mocker.startStubbing();
        MyDependency myMock = (MyDependency) mocker.mock(MyDependency.class);

        // Mocking getContactByEmail return values
        mocker.when(myMock.getContactByEmail('leo@example.com'))
            .thenReturn(new Contact(FirstName = 'Leonardo'));

        mocker.when(myMock.getContactByEmail('berardino@example.com'))
            .thenReturn(new Contact(FirstName = 'Berardino'));

        // Going to the execution phase
        mocker.stopStubbing();

        // Getting the mocked return values

        // It will return Leonardo contact
        Contact contact1 = myMock.getContactByEmail('leo@example.com');
        // It will return Berardino contact
        Contact contact2 = myMock.getContactByEmail('berardino@example.com');
        // It will return null
        Contact contact3 = myMock.getContactByEmail('other@example.com');
    }
}
```

#### Mocking The Method Return For Any Parameter Values

Or you can mock _getContactByEmail_ return value for any email values...

```java
@IsTest
public class MyTest {
    @IsTest
    static void myTestExample01() {
        Mocker mocker = Mocker.startStubbing();
        MyDependency myMock = (MyDependency) mocker.mock(MyDependency.class);

        // Mocking getContactByEmail return values
        mocker.when(myMock.getContactByEmail('')) // It's not necessary to give an email
            .withAnyValues() // Because the parameter value will be ignored
            .thenReturn(new Contact(FirstName = 'Leonardo'));

        // Going to the execution phase
        mocker.stopStubbing();

        // Getting the mocked return values
        // It will return Leonardo contact
        Contact contact1 = myMock.getContactByEmail('leo@example.com');
        // And again Leonardo contact
        Contact contact2 = myMock.getContactByEmail('berardino@example.com');
        // And again :)
        Contact contact3 = myMock.getContactByEmail('other@example.com');
    }
}
```
#### Combining The Mocking Method Return Strategies

Or you can mix both approaches...

```java
@IsTest
public class MyTest {
    @IsTest
    static void myTestExample01() {
        Mocker mocker = Mocker.startStubbing();
        MyDependency myMock = (MyDependency) mocker.mock(MyDependency.class);

        // Mocking getContactByEmail return values
        // Mocking return for Leo email
        mocker.when(myMock.getContactByEmail('leo@example.com'))
            .thenReturn(new Contact(FirstName = 'Leonardo'));

        // And mocking for any values
        mocker.when(myMock.getContactByEmail(''))
            .withAnyValues()
            .thenReturn(new Contact(FirstName = 'Contact for any values'));

        // Going to the execution phase
        mocker.stopStubbing();

        // Getting the mocked return values
        // It will return Leonardo contact
        Contact contact1 = myMock.getContactByEmail('leo@example.com');
        // It will return Contact for any values
        Contact contact2 = myMock.getContactByEmail('berardino@example.com');
        // It will return Contact for any values
        Contact contact3 = myMock.getContactByEmail('other@example.com');
    }
}
```

#### Using Callable To Generate Dynamic Return Values

You can implement the _System.Callable_ interface and use this class to generate dynamic values that will be returned by the mocked method.

The _methodName_ parameter will contain the method name that was called, and the _params_ parameter the arguments passed to it during the method execution.

An example of a callable mock return:

```java
public class GetContactCallableReturn implements Callable {

    public Object call(String methodName, Map<String, Object> params) {
        // Gets the email parameter.
        String email = (String) params.get('email');
        return new Contact(Email = email);
    }
}
```

You can pass your callable class instance on the _.thenReturn_ method. It will instruct the Mocker Framework to ask your callable what the return value is.

```java
    mocker.when(myMock.getContactByEmail('')) // It's not necessary to give an email
        .withAnyValues() // Because the parameter value will be ignored
        .thenReturn(new GetContactCallableReturn()); // Your callable mock return.
```
### Asserting Captured Arguments

The Mocker Framework records all arguments passed to a mock method, and these data are accessible through the _Mocker.MethodRecorder_. It allows you to track and assert all data received by your mock class.

```java
@IsTest
public class MyTest {
    @IsTest
    static void myTestExample01() {
        Mocker mocker = Mocker.startStubbing();
        MyDependency myMock = (MyDependency) mocker.mock(MyDependency.class);

        // Mocks getContactByEmail and gets the method recorder.
        Mocker.MethodRecorder getContactByEmailRec = mocker.when(myMock.getContactByEmail(''))
            .withAnyValues()
            .thenReturn(new Contact(FirstName = 'Contact Name'))
            .getMethodRecorder(); // Allows access to the method recorder.

        // Going to the execution phase
        mocker.stopStubbing();

        // Executes the first call with 'leo@example.com'
        Contact contact1 = myMock.getContactByEmail('leo@example.com');
        // Executes the second call with 'new@example.com'
        Contact contact2 = myMock.getContactByEmail('new@example.com');
        // Executes the third call with 'other@example.com'
        Contact contact3 = myMock.getContactByEmail('other@example.com');

        // Asserts how many call the method getContactByEmail received
        System.assertEquals(3, getContactByEmailRec.getCallsCount());

        // Asserts the arguments received in each call getting
        // these arguments using the parameter name.

        // Asserts the first call.
        System.assertEquals(
            'leo@example.com', getContactByEmailRec.getCallRecording(1).getArgument('email')
        );
        // Asserts the second call.
        System.assertEquals(
            'new@example.com', getContactByEmailRec.getCallRecording(2).getArgument('email')
        );
        // Asserts the third call.
        System.assertEquals(
            'other@example.com', getContactByEmailRec.getCallRecording(3).getArgument('email')
        );
    }
}
```

### Mocking Exceptions

Similar to the return value mocking, you can mock a method to throw an exception.

You can mock _getContactByEmail_ to throw an exception for specific email values...

```java
@IsTest
public class MyTest {
    @IsTest
    static void myTestExample01() {
        Mocker mocker = Mocker.startStubbing();
        MyDependency myMock = (MyDependency) mocker.mock(MyDependency.class);

        // Mocking getContactByEmail return value
        mocker.when(myMock.getContactByEmail('leo@example.com'))
            .thenReturn(new Contact(FirstName = 'Leonardo'));

        // And mocking getContactByEmail exception
        mocker.when(myMock.getContactByEmail('berardino@example.com'))
            .thenThrow(new MyException('Mocked exception'));

        // Going to the execution phase
        mocker.stopStubbing();

        // Getting the mocked return values
        // It will return Leonardo contact
        Contact contact1 = myMock.getContactByEmail('leo@example.com');
        // It will return null
        Contact contact2 = myMock.getContactByEmail('other@example.com');

        try {
            // It will throw MyException
            myMock.getContactByEmail('berardino@example.com');
        } catch(Exception e) {}
    }
}
```

Or you can mock _getContactByEmail_ to throw an exception for any email values...

```java
@IsTest
public class MyTest {
    @IsTest
    static void myTestExample01() {
        Mocker mocker = Mocker.startStubbing();
        MyDependency myMock = (MyDependency) mocker.mock(MyDependency.class);

        // Mocking getContactByEmail return values
        // It's not necessary to set an email
        mocker.when(myMock.getContactByEmail(''))
             // Because the parameter value will be ignored
            .withAnyValues()
            .thenThrow(new MyException('Mocked exception'));

        // Going to the execution phase
        mocker.stopStubbing();

        // Getting the mocked return values
        try {
            // It will throw MyException
            myMock.getContactByEmail(null);
        } catch(Exception e) {}

        try {
            // It will also throw MyException
            myMock.getContactByEmail('berardino@example.com');
        } catch(Exception e) {}
    }
}
```

#### Mocking Void Methods

To mock void methods you will need to call the method you are mocking before the _mocker.when()_ method calling.

```java
@IsTest
public class MyTest {
    @IsTest
    static void myTestExample01() {
        Mocker mocker = Mocker.startStubbing();
        MyDependency myMock = (MyDependency) mocker.mock(MyDependency.class);

        // Mocking getContactByEmail return values
        // Calling the void method before to call the when() method
        myMock.insertContact(new Contact(FirstName = 'Leo'));
        // Mocking the exception
        mocker.when().thenThrow(new MyException('Mocked exception'));

        // Going to the execution phase
        mocker.stopStubbing();

        try {
            // Calling the mocked method
            // It will throw MyException
            myMock.insertContact(new Contact(FirstName = 'Leo'));
        } catch(Exception e) {}

        // Calling a not recorded method (the given Contact is not Leo!)
        // It will not throw an exception
        myMock.insertContact(new Contact(FirstName = 'Berardino'));
    }
}
```

### Creating Expected Methods Behaviours

In some tests we want to know if our mock class has received a method call with some parameter values or how many times a method was called. The Mocker Framework allows you to specify the expected behaviours of mocked methods.
Those behaviours will be asserted when you call Mocker.assert() method.

There are four method behaviours that you can assert:

* The mocked method should be called once => .shouldBeCalledOnce();
* The mocked method should be called N times => .shouldBeCalled(Integer times);
* The mocked method should be never called => shouldNeverBeCalled();
* Mock method should be called between min and max times => shouldBeCalledBetween(Integer minTimes, Integer maxTimes);

To assert if the expected behaviour in your mock class has been executed, you will need to call the _mocker.assert()_ method. This method compares all activities received by your mock during the execution phase with the expected ones. The assertions are made using the Salesforce System.assert operations.

If you want to be notified when an assertion fails, you can call the _mocker.assert(true)_ method with the "true" argument. The Mocker Framework will throw an exception if an assertion fails.

```java
@IsTest
public class MyTest {
    @IsTest
    static void myTestExample01() {
        Mocker mocker = Mocker.startStubbing();
        MyDependency myMock = (MyDependency) mocker.mock(MyDependency.class);

        mocker.when(myMock.getContactByEmail('leo@example.com'))
            // Mocking the return value
            .thenReturn(new Contact(FirstName = 'Leonardo'))
            // Configuring the expected behavior
            .shouldBeCalledOnce();

        mocker.when(myMock.getContactByEmail('berardino@example.com'))
            // Mocking the return value
            .thenReturn(new Contact(FirstName = 'Nicolas'))
            // Configuring the expected behavior
            .shouldBeCalled(3);

        // Going to the execution phase
        mocker.stopStubbing();

        // Executing the test
        Contact contact = myMock.getContactByEmail('leo@example.com');
        // ...

        // Asserts
        System.asserNotEquals(null, contact);
        System.asserEquals('Leonardo', contact.FirstName);
        mocker.assert(); // Assert the expected mock behavior
    }
}
```

### Cleaning recorded actions and behaviours

As explained, the Mocker Framework records what is expected to be done by the mocked class (stubbing phase) and all actions executed on it (execution phase). This internal state can be cleared by calling the method _mocker.clear()_. All previous recorded actions and behaviour will be deleted, and your mock can be stubbed again.

# Mocker Utils

The Mocker Framework also provides the _**MockerUtils**_, a utility class with useful methods to help you develop your unit test class.

## Generating SObjects Ids

You can generate Ids for your mock objects with the method _**generateId**_.

```java

// First call generates the 001000000000001AAA Account Id
Id accountId1 = MockerUtils.generateId(Account.SObjectType);

// Second call generates the 001000000000002AAA Account Id
Id accountId2 = MockerUtils.generateId(Account.SObjectType);

// Generates the 003000000000001AAA Contact Id
Id contactId1 = MockerUtils.generateId(Contact.SObjectType);

// Generates the 003000000969132AAA Contact Id
Id contactId2 = MockerUtils.generateId(Contact.SObjectType, 969132);

```

## Setting Values On Read-Only Fields

Some SObjects fields, such as formula fields, roll-up summary fields or related objects list fields are read-only and cannot be set just using the equal operator. The _MockerUtils_ provides the method _**updateObjectState**_ that allows you to easily update your SObject state even if the fields are read-only.

```java
Account accountInstance = new Account(
    Id = MockerUtils.generateId(Account.SObjectType),
    Name = 'Test Account',
    NumberOfEmployees = 10
);

Contact contact1 = (Contact) MockerUtils.updateObjectState(
    new Contact(FirstName = 'Name'),                // The SObject instance to be updated
    new Map<String, Object>{                        // The Field Name => Data map
        'Id' => MockerUtils.generateId(Contact.SObjectType),
        'Name' => 'Leonardo Berardino',             // Read-only field
        'FirstName' => 'Leonardo',                  // Overrides the FirstName value
        'Birthdate' => Date.today().addYears(-10)   // Date field
    }
);

Contact contact2 = new Contact(
    Id = MockerUtils.generateId(Contact.SObjectType),
    FirstName = 'Another',
    LastName = 'Contact',
    Email = 'test@mockingframework.com'
);

Account updatedAccount = (Account) MockerUtils.updateObjectState(
    accountInstance,                                // The SObject instance to be updated
    new Map<String, Object> {                       // The Field Name => Data map
        'Contacts' => new List<Contact> {           // Sets the read-only contacts list field
            contact1, contact2
        },
        'Website' => 'https://test.com',            // Sets the Website field value
        'Name' => 'New Account Name',               // Overrides the Name field value
        'NumberOfEmployees' => 99                   // Overrides the NumberOfEmployees field
    }
);
```

# Issues And Feature Requests

Use the Github Issues feature to reach out if you have feedback/questions/bugs/feature requests etc.

Please do file any issue you find, keeping the following in mind:

- Create only one issue per bug or feature request.
- Add as much information as possible and the steps to reproduce the error.
- Only add relevant comments to the issues. Many people get notified when a commentary is added to the issue, so let's keep them relevant.

# License

[BSD 3-Clause License](LICENSE)
