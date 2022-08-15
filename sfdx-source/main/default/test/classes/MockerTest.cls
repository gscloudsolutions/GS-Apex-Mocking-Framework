/* Copyright (c) 2022 Groundswell Cloud Solutions Inc. - All Rights Reserved
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND "AS AVAILABLE", WITHOUT WARRANTY OF
 * ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
 * USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/**
 * @description Mocker test class.
 *
 * @author Leonardo Berardino
 */
@IsTest
@SuppressWarnings('pmd.ApexAssertionsShouldIncludeMessage')
public class MockerTest {

    /*
     * @description toReturn method tests
     */
    @IsTest
    static void thenReturnShouldReturnMockedStringWhenCallConcreteClassMethodWithoutParams() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod()).thenReturn('Mocked return string value');
        mocker.stopStubbing();

        // When
        String returnValue = mockedClass.stringReturnMethod();

        // Then
        System.assertEquals('Mocked return string value', returnValue);
    }

    @IsTest
    static void thenReturnShouldReturnMockedStringWhenCallInterfaceMethodWithoutParams() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .shouldBeCalledOnce()
                .thenReturn('Mocked return string value');
        mocker.stopStubbing();

        // When
        String returnValue = mockedClass.stringReturnMethod();

        // Then
        System.assertEquals('Mocked return string value', returnValue);
    }

    @IsTest
    static void thenReturnShouldReturnMockedStringWhenCallMethodWithParams() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);

        mocker.when(mockedClass.stringReturnMethodParams('str1', null))
                .thenReturn('Mocked return for str1, null values');
        mocker.when(mockedClass.stringReturnMethodParams(null, 50))
                .thenReturn('Mocked return for null, 50 values');

        mocker.when(mockedClass.stringReturnMethodParams('str1', 100))
                .thenReturn('Mocked return for str1, 100 values');
        mocker.when(mockedClass.stringReturnMethodParams('str2', 200))
                .thenReturn('Mocked return for str2, 200 values');

        mocker.when(mockedClass.stringReturnMethodParams(100, 'str1'))
                .thenReturn('Mocked return for 100, str1 values');
        mocker.when(mockedClass.stringReturnMethodParams(200, 'str2'))
                .thenReturn('Mocked return for 200, str2 values');

        mocker.stopStubbing();

        // When
        String returnValueStrNull = mockedClass.stringReturnMethodParams('str1', null);
        String returnValueNull50 = mockedClass.stringReturnMethodParams(null, 50);

        String returnValueStr100 = mockedClass.stringReturnMethodParams('str1', 100);
        String returnValueStr200 = mockedClass.stringReturnMethodParams('str2', 200);
        String returnValueStr300 = mockedClass.stringReturnMethodParams('str3', 300);

        String returnValue100Str1 = mockedClass.stringReturnMethodParams(100, 'str1');
        String returnValue200Str2 = mockedClass.stringReturnMethodParams(200, 'str2');
        String returnValue300Str3 = mockedClass.stringReturnMethodParams(300, 'str3');

        // Then
        System.assertEquals('Mocked return for str1, null values', returnValueStrNull);
        System.assertEquals('Mocked return for null, 50 values', returnValueNull50);

        System.assertEquals('Mocked return for str1, 100 values', returnValueStr100);
        System.assertEquals('Mocked return for str2, 200 values', returnValueStr200);
        System.assertEquals(null, returnValueStr300);

        System.assertEquals('Mocked return for 100, str1 values', returnValue100Str1);
        System.assertEquals('Mocked return for 200, str2 values', returnValue200Str2);
        System.assertEquals(null, returnValue300Str3);
    }

    @IsTest
    static void thenReturnShouldReturnMockedContactByEmail() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);

        mocker.when(mockedClass.getContact('leonardo@exemple.com'))
                .thenReturn(new Contact(FirstName = 'Leonardo'));
        mocker.when(mockedClass.getContact('nicolas@exemple.com'))
                .thenReturn(new Contact(FirstName = 'Nicolas'));

        mocker.stopStubbing();

        // When
        Contact contact1 = mockedClass.getContact('leonardo@exemple.com');
        Contact contact2 = mockedClass.getContact('nicolas@exemple.com');
        Contact contact3 = mockedClass.getContact('other@exemple.com');

        // Then
        System.assertEquals(new Contact(FirstName = 'Leonardo'), contact1);
        System.assertEquals(new Contact(FirstName = 'Nicolas'), contact2);
        System.assertEquals(null, contact3);
    }

    @IsTest
    static void thenReturnShouldReturnMockedContactForAnyEmails() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);

        mocker.when(mockedClass.getContact('leonardo@exemple.com'))
                .thenReturn(new Contact(FirstName = 'Leonardo'));
        mocker.when(mockedClass.getContact(''))
                .withAnyValues()
                .thenReturn(new Contact(FirstName = 'For any values'));

        mocker.stopStubbing();

        // When
        Contact contact1 = mockedClass.getContact('leonardo@exemple.com');
        Contact contact2 = mockedClass.getContact('nicolas@exemple.com');
        Contact contact3 = mockedClass.getContact('other@exemple.com');

        // Then
        System.assertEquals(new Contact(FirstName = 'Leonardo'), contact1);
        System.assertEquals(new Contact(FirstName = 'For any values'), contact2);
        System.assertEquals(new Contact(FirstName = 'For any values'), contact3);
    }

    @IsTest
    static void thenReturnShouldReturnMockedValueCreatedByCallableReturn() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);

        mocker.when(mockedClass.getContact(''))
                .withAnyValues()
                .thenReturn(new GetContactCallableReturn());
        mocker.stopStubbing();

        // When
        Contact contact1 = mockedClass.getContact('leonardo@exemple.com');
        Contact contact2 = mockedClass.getContact('nicolas@exemple.com');
        Contact contact3 = mockedClass.getContact('other@exemple.com');

        // Then
        System.assertEquals('leonardo@exemple.com', contact1.Email);
        System.assertEquals('nicolas@exemple.com', contact2.Email);
        System.assertEquals('other@exemple.com', contact3.Email);
    }

    /*
     * toReturn method tests with any values
     */
    @IsTest
    static void thenReturnWithAnyValuesShouldReturnMockedStringWhenCallMethodWithParamsWithAnyValues() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);

        mocker.when(mockedClass.stringReturnMethodParams('', 0))
                .withAnyValues()
                .thenReturn('Mocked return for String, Integer');
        mocker.when(mockedClass.stringReturnMethodParams(0, ''))
                .withAnyValues()
                .thenReturn('Mocked return for Integer, String');

        mocker.stopStubbing();

        // When
        String returnValueStr100 = mockedClass.stringReturnMethodParams('str1', 100);
        String returnValueStr200 = mockedClass.stringReturnMethodParams('str2', 200);
        String returnValue100Str1 = mockedClass.stringReturnMethodParams(100, 'str1');
        String returnValue200Str2 = mockedClass.stringReturnMethodParams(200, 'str2');

        // Then
        System.assertEquals('Mocked return for String, Integer', returnValueStr100);
        System.assertEquals('Mocked return for String, Integer', returnValueStr200);
        System.assertEquals('Mocked return for Integer, String', returnValue100Str1);
        System.assertEquals('Mocked return for Integer, String', returnValue200Str2);
    }

    /*
     * Mixed tests
     */
    @IsTest
    static void thenReturnMixedShouldReturnMockedStringForEachCase() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);

        mocker.when(mockedClass.stringReturnMethodParams('str1', 100))
                .thenReturn ('Mocked return for String, Integer with str1, 100 values');
        mocker.when(mockedClass.stringReturnMethodParams('', 0))
                .withAnyValues()
                .thenReturn('Mocked return for String, Integer with any values');

        mocker.when(mockedClass.stringReturnMethodParams(100, 'str1'))
                .thenReturn ('Mocked return for Integer, String with 100, str1 values');
        mocker.when(mockedClass.stringReturnMethodParams(0, ''))
                .withAnyValues()
                .thenReturn('Mocked return for Integer, String with any values');

        mocker.stopStubbing();

        // When
        String returnValueStr100 = mockedClass.stringReturnMethodParams('str1', 100);
        String returnValueStr200 = mockedClass.stringReturnMethodParams('str2', 200);
        String returnValue100Str1 = mockedClass.stringReturnMethodParams(100, 'str1');
        String returnValue200Str2 = mockedClass.stringReturnMethodParams(100, 'str2');

        // Then
        System.assertEquals('Mocked return for String, Integer with str1, 100 values', returnValueStr100);
        System.assertEquals('Mocked return for String, Integer with any values', returnValueStr200);
        System.assertEquals('Mocked return for Integer, String with 100, str1 values', returnValue100Str1);
        System.assertEquals('Mocked return for Integer, String with any values', returnValue200Str2);
    }

    @IsTest
    static void thenReturnAndThenThrowShouldReturnOrThrowExceptionForEachCase() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);

        mocker.when(mockedClass.stringReturnMethodParams('str1', 100))
                .thenReturn ('Mocked return for str1, 100 values');
        mocker.when(mockedClass.stringReturnMethodParams('str2', 200))
                .thenThrow(new MockerTestException('Str2, 200 values exception'));
        mocker.when(mockedClass.stringReturnMethodParams('', 0))
                .withAnyValues()
                .thenReturn('Mocked return for any values');

        mocker.stopStubbing();

        // When
        String returnValueStr100 = mockedClass.stringReturnMethodParams('str1', 100);
        String returnValueStr300 = mockedClass.stringReturnMethodParams('str3', 300);
        try {
            mockedClass.stringReturnMethodParams('str2', 200);
            System.assert(false, 'Should throw MockerTestException');

        } catch(Exception e) {
            // Then
            System.assert(e instanceof MockerTestException, 'Should throw MockerTestException');
            System.assertEquals('Str2, 200 values exception', e.getMessage());
        }
        // Then
        System.assertEquals('Mocked return for str1, 100 values', returnValueStr100);
        System.assertEquals('Mocked return for any values', returnValueStr300);
    }

    /*
     * thenThrow method tests
     */
    @IsTest
    static void thenThrowShouldThrowExceptionWhenCallVoidMethodWithoutParams() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mockedClass.voidMethod();
        mocker.when().thenThrow(new MockerTestException('Mocked exception message'));
        mocker.stopStubbing();

        try {
            // When
            mockedClass.voidMethod();
            System.assert(false, 'Should throw MockerTestException');

        } catch(Exception e) {
            // Then
            System.assert(e instanceof MockerTestException, 'Should throw MockerTestException');
            System.assertEquals('Mocked exception message', e.getMessage());
        }
    }

    @IsTest
    static void thenThrowShouldThrowExceptionWhenCallVoidMethodWithParams() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);

        mockedClass.voidMethod('str1', 100);
        mocker.when().thenThrow(new MockerTestException('Mocked exception for str1, 100 values'));

        mockedClass.voidMethod('str2', 200);
        mocker.when().thenThrow(new MockerTestException('Mocked exception for str2, 200 values'));

        mocker.stopStubbing();

        try {
            // When for str1, 100 values
            mockedClass.voidMethod('str1', 100);
            System.assert(false, 'Should throw MockerTestException');

        } catch(Exception e) {
            // Then for str1, 100 values
            System.assert(e instanceof MockerTestException, 'Should throw MockerTestException');
            System.assertEquals('Mocked exception for str1, 100 values', e.getMessage());
        }

        try {
            // When for str2, 200 values
            mockedClass.voidMethod('str2', 200);
            System.assert(false, 'Should throw MockerTestException');

        } catch(Exception e) {
            // Then for str2, 200 values
            System.assert(e instanceof MockerTestException, 'Should throw MockerTestException');
            System.assertEquals('Mocked exception for str2, 200 values', e.getMessage());
        }

        try {
            // When for str3, 300 values
            mockedClass.voidMethod('str3', 300);

            // Then for str3, 300 values
            System.assert(true);

        } catch(Exception e) {
            System.assert(false, 'Should NOT throw MockerTestException');
        }
    }

    @IsTest
    static void thenThrowShouldThrowExceptionWhenTryToInsertSpecificContact() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);

        mockedClass.insertContact(new Contact(FirstName = 'Leo'));
        mocker.when().thenThrow(new MockerTestException('Error inserting Leo Contact'));

        mocker.stopStubbing();

        try {
            // When for Contact Leo
            mockedClass.insertContact(new Contact(FirstName = 'Leo'));
            System.assert(false, 'Should throw MockerTestException');

        } catch(Exception e) {
            // Then for str1, 100 values
            System.assert(e instanceof MockerTestException, 'Should throw MockerTestException');
            System.assertEquals('Error inserting Leo Contact', e.getMessage());
        }

        try {
            // When for contact Nicolas
            mockedClass.insertContact(new Contact(FirstName = 'Nicolas'));
            System.assert(true);

        } catch(Exception e) {
            System.assert(false, 'Should NOT throw MockerTestException');
        }
    }

    /*
     * assert method tests: For call Once
     */
    @IsTest
    static void assertShouldPassWithOneCallWhenExpectedBeCalledOnce() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .thenReturn('Mocked return value')
                .shouldBeCalledOnce();
        mocker.stopStubbing();

        // When with on call
        String returnValue = mockedClass.stringReturnMethod();

        // Then
        System.assertEquals('Mocked return value', returnValue);
        mocker.assert();
    }

    @IsTest
    static void assertShouldFailWithNoCallsWhenExpectedBeCalledOnce() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .shouldBeCalledOnce();
        mocker.stopStubbing();

        // When with no calls

        // Then
        try {
            mocker.assert(true);
            System.assert(false, 'Should throw and exception');

        } catch(Exception e) {
            System.assert(e instanceof MockerException, 'Should be MockerException instance');
            System.assertEquals('Method stringReturnMethod() should be called once', ((MockerException) e).getMessage());
        }
    }

    @IsTest
    static void assertShouldFailWithMoreThanOneCallWhenExpectedBeCalledOnce() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .shouldBeCalledOnce();
        mocker.stopStubbing();

        // When with more than one call
        mockedClass.stringReturnMethod();
        mockedClass.stringReturnMethod();

        // Then
        try {
            mocker.assert(true);
            System.assert(false, 'Should throw and exception');

        } catch(Exception e) {
            System.assert(e instanceof MockerException, 'Should be MockerException instance');
            System.assertEquals('Method stringReturnMethod() should be called once', ((MockerException) e).getMessage());
        }
    }

    /*
     * @description assert method tests: For never be called
     */
    @IsTest
    static void assertShouldPassWithNoCallsWhenExpectedNeverBeCalled() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .shouldNeverBeCalled();
        mocker.stopStubbing();

        // When with call on not tracked method
        mockedClass.voidMethod();

        // Then
        mocker.assert();
        System.assert(true, 'Test should no fail');
    }

    @IsTest
    static void assertShouldFailWithOnceCallWhenExpectedNeverBeCalled() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .shouldNeverBeCalled();
        mocker.stopStubbing();

        // When with on call
        mockedClass.stringReturnMethod();

        // Then
        try {
            mocker.assert(true);
            System.assert(false, 'Should throw and exception');

        } catch(Exception e) {
            System.assert(e instanceof MockerException, 'Should be MockerException instance');
            System.assertEquals('Method stringReturnMethod() should never be called', ((MockerException) e).getMessage());
        }
    }

    @IsTest
    static void assertShouldFailWithManyCallsWhenExpectedNeverBeCalled() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .shouldNeverBeCalled();
        mocker.stopStubbing();

        // When with more than one call
        mockedClass.stringReturnMethod();
        mockedClass.stringReturnMethod();

        // Then
        try {
            mocker.assert(true);
            System.assert(false, 'Should throw and exception');

        } catch(Exception e) {
            System.assert(e instanceof MockerException, 'Should be MockerException instance');
            System.assertEquals('Method stringReturnMethod() should never be called', ((MockerException) e).getMessage());
        }
    }

    /*
     * assert method tests: For called N times
     */
    @IsTest
    static void assertShouldPassWith3CallsWhenExpectedBeCalled3Times() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .shouldBeCalled(3);
        mocker.stopStubbing();

        // When with 3 calls
        mockedClass.stringReturnMethod();
        mockedClass.stringReturnMethod();
        mockedClass.stringReturnMethod();

        // Then
        mocker.assert();
        System.assert(true, 'Test should no fail');
    }

    @IsTest
    static void assertShouldFailWithOneCallWhenExpectedBeCalled3Times() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .shouldBeCalled(3);
        mocker.stopStubbing();

        // When with one call
        mockedClass.stringReturnMethod();

        // Then
        try {
            mocker.assert(true);
            System.assert(false, 'Should throw and exception');

        } catch(Exception e) {
            System.assert(e instanceof MockerException, 'Should be MockerException instance');
            System.assertEquals('Method stringReturnMethod() should be called 3 times', ((MockerException) e).getMessage());
        }
    }

    @IsTest
    static void assertShouldFailWithTwoCallsWhenExpectedBeCalled3Times() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .shouldBeCalled(3);
        mocker.stopStubbing();

        // When with more than one call
        mockedClass.stringReturnMethod();
        mockedClass.stringReturnMethod();

        // Then
        try {
            mocker.assert(true);
            System.assert(false, 'Should throw and exception');

        } catch(Exception e) {
            System.assert(e instanceof MockerException, 'Should be MockerException instance');
            System.assertEquals('Method stringReturnMethod() should be called 3 times', ((MockerException) e).getMessage());
        }
    }

    @IsTest
    static void assertShouldFailWithFourCallsWhenExpectedBeCalled3Times() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethodParams('test', 123))
                .shouldBeCalled(3);
        mocker.stopStubbing();

        // When with more than one call
        mockedClass.stringReturnMethodParams('test', 123);
        mockedClass.stringReturnMethodParams('test', 123);
        mockedClass.stringReturnMethodParams('test', 123);
        mockedClass.stringReturnMethodParams('test', 123);

        // Then
        try {
            mocker.assert(true);
            System.assert(false, 'Should throw and exception');

        } catch(Exception e) {
            System.assert(e instanceof MockerException, 'Should be MockerException instance');
            System.assertEquals('Method stringReturnMethodParams(String, Integer) should be called 3 times', ((MockerException) e).getMessage());
        }
    }

    /*
     * @description assert method tests: For called between times
     */
    @IsTest
    static void assertShouldPassWithOneCallWhenExpectedBeCalledBetween1And2Times() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .shouldBeCalledBetween(1, 2);
        mocker.stopStubbing();

        // When with 1 calls
        mockedClass.stringReturnMethod();

        // Then
        mocker.assert();
        System.assert(true, 'Test should no fail');
    }

    @IsTest
    static void assertShouldPassWithTwoCallsWhenExpectedBeCalledBetween1And2Times() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .shouldBeCalledBetween(1, 2);
        mocker.stopStubbing();

        // When with 2 calls
        mockedClass.stringReturnMethod();
        mockedClass.stringReturnMethod();

        // Then
        mocker.assert();
        System.assert(true, 'Test should no fail');
    }

    @IsTest
    static void assertShouldFailWithThreeCallsWhenExpectedBeCalledBetween1And2Times() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .shouldBeCalledBetween(1, 2);
        mocker.stopStubbing();

        // When with 3 calls
        mockedClass.stringReturnMethod();
        mockedClass.stringReturnMethod();
        mockedClass.stringReturnMethod();

        // Then
        try {
            mocker.assert(true);
            System.assert(false, 'Should throw and exception');

        } catch(Exception e) {
            System.assert(e instanceof MockerException, 'Should be MockerException instance');
            System.assertEquals('Method stringReturnMethod() should be called between 1 and 2 times', ((MockerException) e).getMessage());
        }
    }

    @IsTest
    static void assertShouldFailWithNoCallsWhenExpectedBeCalledBetween1And2Times() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .shouldBeCalledBetween(1, 2);
        mocker.stopStubbing();

        // When calling not recorded method
        mockedClass.voidMethod();

        // Then
        try {
            mocker.assert(true);
            System.assert(false, 'Should throw and exception');

        } catch(Exception e) {
            System.assert(e instanceof MockerException, 'Should be MockerException instance');
            System.assertEquals('Method stringReturnMethod() should be called between 1 and 2 times', ((MockerException) e).getMessage());
        }
    }

    /*
     * clear method tests
     */
    @IsTest
    static void clearShouldReturnMockedStringWhenCallConcreteClassMethodWithoutParams() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .thenReturn('Mocked return string value');
        mocker.stopStubbing();

        // When
        mocker.clear();
        mocker.when(mockedClass.stringReturnMethodParams('str', 100))
                .thenReturn('Mocked return str, 100 values');
        mocker.stopStubbing();
        mocker.stopStubbing();

        // Then cleared record
        String returnValue1 = mockedClass.stringReturnMethod();
        System.assertEquals(null, returnValue1);

        // Then second record
        String returnValue2 = mockedClass.stringReturnMethodParams('str', 100);
        System.assertEquals('Mocked return str, 100 values', returnValue2);
    }

    /*
     * Method order tests
     */
    @IsTest
    static void assertShouldAssertMethodCallsWhenWithAnyValuesIsCalledBeforeCallBehaviour() {
        // Given
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .withAnyValues()
                .shouldBeCalled(2);
        mocker.stopStubbing();

        // When calling the method 2 times
        mockedClass.stringReturnMethod();
        mockedClass.stringReturnMethod();

        // Then
        mocker.assert();
        System.assert(true, 'Test should no fail');
    }

    @IsTest
    static void assertShouldAssertMethodCallsWhenWithAnyValuesIsCalledAfterCallBehaviour() {
        // Given
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        mocker.when(mockedClass.stringReturnMethod())
                .shouldBeCalled(2)
                .withAnyValues();
        mocker.stopStubbing();

        // When calling the method 2 times
        mockedClass.stringReturnMethod();
        mockedClass.stringReturnMethod();

        // Then
        mocker.assert();
        System.assert(true, 'Test should no fail');
    }

    /*
     * Method recording tests
     */
    @IsTest
    static void thenReturnShouldGetArgumentsForEachMockMethodCall() {
        // Given this records mock behavior
        Mocker mocker = Mocker.startStubbing();
        MockerTestFixture mockedClass = (MockerTestFixture) mocker.mock(MockerTestFixture.class);
        Mocker.MethodRecorder getContactRec = mocker.when(mockedClass.getContact(''))
            .withAnyValues()
            .thenReturn(new Contact(Email = 'mocker@email.com'))
            .getMethodRecorder();
        mocker.stopStubbing();

        // When call 1
        Contact contact1 = mockedClass.getContact('leonardo@test.com');
        // When call 2
        Contact contact2 = mockedClass.getContact('berardino@test.com');

        // Then
        System.assertEquals(2, getContactRec.getCallsCount());
        System.assertEquals('mocker@email.com', contact1.Email);
        System.assertEquals('mocker@email.com', contact2.Email);
        System.assertEquals('leonardo@test.com', getContactRec.getCallRecording(1).getArgument('email'));
        System.assertEquals('berardino@test.com', getContactRec.getCallRecording(2).getArgument('email'));
    }

    /*
     * Text fixtures
     */

     /**
      * @description Callable test class
      */
    public class GetContactCallableReturn implements Callable {

        /**
         * @description Call method
         * @param methodName The called method name
         * @param params The called method parameters
         * @return A contact with the given email parameter
         */
        public Object call(String methodName, Map<String, Object> params) {
            // Gets the email parameter
            String email = (String) params.get('email');
            return new Contact(Email = email);
        }
    }
}
