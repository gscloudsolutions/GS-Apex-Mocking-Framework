/* Copyright (c) 2022 Groundswell Cloud Solutions Inc. - All Rights Reserved
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND "AS AVAILABLE", WITHOUT WARRANTY OF
 * ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
 * USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/**
 * @description A Mock framework implementation
 *
 * @author Leonardo Berardino
 */
@IsTest
public class Mocker {

    /**
     * @description Mocker provider map by mock instance
     */
    private Map<Object, MockProvider> providers = new Map<Object, MockProvider>();

    /**
     * @description The last mock instance enabled. The mocker provider returned by
     *              when() method it'll be of this mock instance
     */
    private Object lastEnabledMockInstance;

    /**
     * @description Mocker private constructor
     */
    @SuppressWarnings('pmd.EmptyStatementBlock')
    private Mocker() {
        // This class is constructed only via the startStubbing factory method
    }

    /**
     * @description Starts the mocking stub process
     *
     * @return The mocker instance
     */
    public static Mocker startStubbing() {
        return new Mocker();
    }

    /**
     * @description Mocks a class or an interface
     *
     * @param mockTarget The class or interface type to be mocked
     * @return The mock instance for the given interface or class
     */
    public Object mock(Type mockTarget) {
        MockProvider mockProvider = new MockProvider(this);
        Object mock = Test.createStub(mockTarget, mockProvider);
        providers.put(mock, mockProvider);
        return mock;
    }

    /**
     * @description Gets the mocker provider for the last called method allowing
     *              to record operations and assertions for that method
     *
     * @return The mock provider instance for the last called method
     */
    public IMockerProvider when() {
        if(this.lastEnabledMockInstance == null) {
            throw new MockerException('Invalid stubbing calling order. ' +
                    'Try to call your mocking method inside the expect([your method call here!]) method call.');
        }
        IMockerProvider mockProvider = providers.get(this.lastEnabledMockInstance);
        if(mockProvider == null) {
            throw new MockerException('Mocker provider for your mock instance not found!');
        }
        this.lastEnabledMockInstance = null;
        return mockProvider;
    }

    /**
     * @description Gets the mocker provider for the method called in the parameter
     *              allowing to record operations and assertions for that method
     *
     * @param mockMethodCall Not used parameter
     * @return The mock provider instance for the last called method
     */
    public IMockerProvider when(Object mockMethodCall) {
        return when();
    }

    /**
     * @description Stops the stubbing phase enabling the replay phase
     *              After stop stubbing the mocker will start replay the recorded operations
     */
    public void stopStubbing() {
        this.lastEnabledMockInstance = null;
        for(MockProvider mockProvider : this.providers.values()) {
            mockProvider.stopStubbing();
        }
    }

    /**
     * @description Clear all recorded operations during the stubbing phase
     *              Resets the mocker to the initial stubbing phase
     */
    public void clear() {
        for(MockProvider mockProvider : this.providers.values()) {
            mockProvider.clear();
        }
    }

    /**
     * @description Sets the last mock instance enabled. The mocker provider returned by
     *              when() method it'll be of this mock instance
     *
     * @param mockInstance Sets the last mock instance
     */
    public void setLastEnabledMockInstance(Object mockInstance) {
        this.lastEnabledMockInstance = mockInstance;
    }

    /**
     * @description Asserts the mocker execution statistics using the constraints
     *              created in the stubbing phase
     */
    public void assert() {
        assert(false);
    }

    /**
     * @description Asserts the mocker execution statistics using the constraints
     *              created in the stubbing phase
     *
     * @param throwAnException When True, instead of use System.assert for the
     * assertion, it will throw a MockException if the assertion fails
     */
    public void assert(Boolean throwAnException) {
        for(MockProvider mockProvider : this.providers.values()) {
            mockProvider.assert(throwAnException);
        }
    }

    /**
     * @description Wrapper class for a mock method calls recording
     *              Wraps the data recorded during the test execution
     */
    public class MethodRecorder {

        /**
         * @description The data recorded during the test execution
         */
        private MockProvider.MockData mockData;

        /**
         * @description Mock method recording class constructor
         *
         * @param mockData The data recorded during the test execution
         */
        public MethodRecorder(MockProvider.MockData mockData) {
            this.mockData = mockData;
        }

        /**
         * @description Gets the method call recorded data
         *
         * @param callNumber The method call number
         * @return The method call recorded data
         */
        public CallRecording getCallRecording(Integer callNumber) {
            Map<String, Object> arguments = this.mockData.getCallArguments(callNumber);
            return new CallRecording(arguments);
        }

        /**
         * @description Gets the number of the method calls
         *
         * @return The number of the method calls
         */
        public Integer getCallsCount() {
            return mockData.callTimes;
        }
    }

    /**
     * @description Wrapper class for a specific mock method call recording
     *              Wraps the data recorded for a specific method call during the test execution
     */
    public class CallRecording {

        /**
         * @description The recorded method call parameters and arguments
         */
        private Map<String, Object> callArguments;

        /**
         * @description Mock method call recording constructor
         *
         * @param callArguments  The data recorded during the test execution
         */
        public CallRecording(Map<String, Object> callArguments) {
            this.callArguments = callArguments;
        }

        /**
         * @description Gets the recorded parameter argument
         *
         * @param paramName The parameter name
         * @return The recorded received argument
         */
        public Object getArgument(String paramName) {
            return this.callArguments.get(paramName);
        }
    }
}
