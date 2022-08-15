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
 * @description Provides a mock operation recording and assertion
 *
 * @author Leonardo Berardino
 */
@IsTest
@SuppressWarnings('pmd.ExcessivePublicCount')
public class MockProvider implements System.StubProvider, IMockerProvider {

    /**
     * @description The mock phases enum
     */
    private enum MockerPhase {
        RECORDING, EXECUTING
    }

    /**
     * @description The current mock phase
     */
    private MockerPhase phase = MockerPhase.RECORDING;
    /**
     * @description The hash key for the current stubbed method including arguments
     */
    private Integer methodKey;
    /**
     * @description The hash key for the current stubbed method without compute arguments
     */
    private Integer methodKeyForAnyValues;
    /**
     * @description Current mock recording and statistics data indexed by method hash key
     */
    private Map<Integer, MockData> mockDataMap = new Map<Integer, MockData>();
    /**
     * @description The mocker framework instance
     */
    private Mocker mocker;

    /**
     * @description The mocker provider constructor
     *
     * @param mockerInstance The mocker framework instance
     */
    public MockProvider(Mocker mockerInstance) {
        this.mocker = mockerInstance;
    }

    /**
     * @description Stops the recording phase for the current mock
     */
    public void stopStubbing() {
        this.methodKey = null;
        this.methodKeyForAnyValues = null;
        this.phase = MockerPhase.EXECUTING;
    }

    /**
     * @description Clear the recorded and statistics data for the current mock
     */
    public void clear() {
        this.methodKey = null;
        this.methodKeyForAnyValues = null;
        this.mockDataMap = new Map<Integer, MockData>();
        this.phase = MockerPhase.RECORDING;
    }

    /**
     * @description Mock method call handler from Salesforce Stub API. Records the
     *              mock operations during the recording phase and replays the recorded
     *              operations during the execution phase
     *
     * @param stubbedObject The mock instance
     * @param methodName The called method name
     * @param returnType The called method return type
     * @param paramTypes The called method parameters types
     * @param paramNames The called method parameters names
     * @param arguments The called method arguments
     * @return The mocked method return value
     */
    @SuppressWarnings('pmd.ExcessiveParameterList')
    public Object handleMethodCall(
        Object stubbedObject,
        String methodName,
        Type returnType,
        List<Type> paramTypes,
        List<String> paramNames,
        List<Object> arguments)
    {
        Integer methodKey = generateMethodHashKey(methodName, paramTypes, arguments);
        Integer methodKeyForAnyValues = generateMethodHashKey(methodName, paramTypes);

        // Recording phase
        if(this.phase == MockerPhase.RECORDING) {
            this.mocker.setLastEnabledMockInstance(stubbedObject);
            this.methodKey = methodKey;
            this.methodKeyForAnyValues = methodKeyForAnyValues;
            this.mockDataMap.put(this.methodKey, new MockData(methodName, paramNames, paramTypes));
            return null;
        }

        // Executing phase for specific arguments
        MockData mockData = this.mockDataMap.get(methodKey);
        if(mockData != null) {
            return mockData.doExecute(arguments);
        }

        // Executing phase for any argument
        mockData = this.mockDataMap.get(methodKeyForAnyValues);
        return mockData == null ? null : mockData.doExecute(arguments);
    }

    /**
     * @description Enables the stubbing for the current called method without compute
     *              the received arguments
     *
     * @return The current mock provider instance
     */
    public IMockerProvider withAnyValues() {
        MockData mockData = getMockData();
        this.mockDataMap.remove(this.methodKey);
        this.mockDataMap.put(this.methodKeyForAnyValues, mockData);
        return this;
    }

    /**
     * @description Asserts this mock replay statistics using the constraints
     *              created on the stubbing phase
     *
     * @param throwAnException When True, instead of use System.assert for the
     *        assertion, it will throw a MockException if the assertion fails
     */
    public void assert(Boolean throwAnException) {
        for(MockData mockData : this.mockDataMap.values()) {
            mockData.assert(throwAnException);
        }
    }

    /**
     * @description Mocks the current method return value
     *
     * @param mockReturnValue The current method mocked return value
     * @return The current mock provider instance
     */
    public IMockerProvider thenReturn(Object mockReturnValue) {
        setReturnValue(mockReturnValue);
        return this;
    }

    /**
     * @description Mocks the current method exception
     *
     * @param exceptionToThrow The exception that will be thrown when the mock method will called
     * @return The current mock provider instance
     */
    public IMockerProvider thenThrow(Exception exceptionToThrow) {
        setException( exceptionToThrow);
        return this;
    }

    /**
     * @description Creates an assertion constraint indicating that the current mocked method
     *              only can be called one time. This assertion constraint will be verified during the
     *              assertion phase
     *
     * @return The current mock provider instance
     */
    public IMockerProvider shouldBeCalledOnce() {
        return shouldBeCalled(1);
    }

    /**
     * @description Creates an assertion constraint indicating that the current mocked method
     *              only can be called the given times. This assertion constraint will be verified during
     *              the assertion phase
     *
     * @param times The number of calls constraint
     * @return The current mock provider instance
     */
    public IMockerProvider shouldBeCalled(Integer times) {
        return shouldBeCalledBetween(times, times);
    }

    /**
     * @description Creates an assertion constraint indicating that the current mocked method
     *              cannot be called. This assertion constraint will be verified during the
     *              assertion phase
     *
     * @return The current mock provider instance
     */
    public IMockerProvider shouldNeverBeCalled() {
        return shouldBeCalled(0);
    }

    /**
     * @description Creates an assertion constraint indicating that the current mocked method
     *              only can be called between the min and max given times. This assertion constraint will
     *              be verified during the assertion phase
     *
     * @param minTimes The minimum number of calls constraint
     * @param maxTimes The maximum number of calls constraint
     * @return The current mock provider instance
     */
    public IMockerProvider shouldBeCalledBetween(Integer minTimes, Integer maxTimes) {
        setCallTimes(minTimes, maxTimes);
        return this;
    }

    /**
     * @description Gets the method executing recording data
     *
     * @return The method executing recording data
     */
    public Mocker.MethodRecorder getMethodRecorder() {
        return new Mocker.MethodRecorder(this.getMockData());
    }

    /**
     * @description Gets the current mock method mock data
     *
     * @return The current method mock data
     */
    private MockData getMockData() {
        return this.mockDataMap.containsKey(this.methodKey)
            ? this.mockDataMap.get(this.methodKey)
            : this.mockDataMap.get(this.methodKeyForAnyValues);
    }

    /**
     * @description Sets the current method call constraint
     *
     * @param minTimes The minimum number of calls constraint
     * @param maxTimes The maximum number of calls constraint
     */
    private void setCallTimes(Integer minTimes, Integer maxTimes) {
        MockData mockData = getMockData();
        if(mockData == null) {
            return;
        }
        mockData.minTimes = minTimes;
        mockData.maxTimes = maxTimes;
    }

    /**
     * @description Sets the current method mocked return value
     *
     * @param value The mocked return value
     */
    private void setReturnValue(Object value) {
        MockData mockData = getMockData();
        if(mockData == null) {
            return;
        }
        mockData.returnValue = value;
    }

    /**
     * @description Sets the current method exception
     *
     * @param exceptionToThrow The mocked method exception
     */
    private void setException(Exception exceptionToThrow) {
        MockData mockData = getMockData();
        if(mockData == null) {
            return;
        }
        mockData.exceptionToThrow = exceptionToThrow;
    }

    /**
     * @description Generates the method signature for the given method types
     *
     * @param methodName The method name
     * @param paramTypes The method parameters types
     * @return The method signature
     */
    private Integer generateMethodHashKey(String methodName, List<Type> paramTypes) {
        return generateMethodHashKey(methodName, paramTypes, null);
    }

    /**
     * @description Generates the method signature for the given method types and parameter values
     *
     * @param methodName The method name
     * @param paramTypes The method parameters types
     * @param arguments The method arguments
     * @return The method signature
     */
    private Integer generateMethodHashKey(String methodName, List<Type> paramTypes, List<Object> arguments) {
        String signature = methodName;
        List<String> params = new List<String>();
        for(Integer i = 0; i < paramTypes.size(); i++) {
            String param = String.valueOf(paramTypes[i]);
            if(arguments != null) {
                param += ' => ' + String.valueOf(arguments[i]);
            }
            params.add(param);
        }
        return System.hashCode(signature + '(' + String.join(params, ',') + ')');
    }

    /**
     * @description MockerProvider:
     *              Mock -> Mock.Method(integer, string) -> return (value1)
     *                   -> Mock.Method(integer 20, string 'test')  -> MockData -> return (value2)
     *                   -> Mock.Method(integer 30, string 'test2') -> MockData -> return (value3)
     * The mocked method data and statistics
     */
    public class MockData {
        /**
         * @description The method calls received arguments
         *              Calling number -> Map( parameterName -> argument )
         */
        private Map<Integer, Map<String, Object>> callArgumentsByParamName = new Map<Integer, Map<String, Object>>();
        /**
         * @description The number of times the mocked method was called
         */
        public Integer callTimes { get; private set; }
        /**
         * @description The mocked method named
         */
        public String methodName { get; private set; }
        /**
         * @description The method parameters names
         */
        public List<String> paramNames { get; private set; }
        /**
         * @description The method parameters types
         */
        public List<Type> paramTypes { get; private set; }

        /**
         * @description The mocked data default constructor
         *
         * @param methodName The mocked method signature
         * @param paramNames The method parameters names
         * @param paramTypes The method parameters types
         */
        public MockData(String methodName, List<String> paramNames, List<Type> paramTypes) {
            this.methodName = methodName;
            this.paramNames = paramNames;
            this.paramTypes = paramTypes;
            this.callTimes = 0;
        }

        /**
         * @description Minimum call times constraint
         */
        public Integer minTimes { get; set {
            minTimes = value;
        }}

        /**
         * @description Maximum call times constraint
         */
        public Integer maxTimes { get; set {
            maxTimes = value;
        }}

        /**
         * @description Mocked method return value
         */
        public Object returnValue { get; set {
            returnValue = value;
        }}

        /**
         * @description Mocked method exception
         */
        public Exception exceptionToThrow { get; set {
            exceptionToThrow = value;
        }}

        /**
         * @description Executes the mock method recorded actions and updates the method call statistics
         *
         * @param arguments The arguments for the current execution
         * @return The mocked return value if it was recorded, otherwise null
         */
        public Object doExecute(List<Object> arguments) {
            this.callTimes++;
            Map<String, Object> argumentsByParamName = this.indexArgumentsByParamName(arguments);
            this.callArgumentsByParamName.put(callTimes, argumentsByParamName);
            if(this.exceptionToThrow != null) {
                throw this.exceptionToThrow;
            }
            return this.returnValue instanceof Callable
                ? ((Callable) this.returnValue).call(this.methodName, argumentsByParamName)
                : this.returnValue;
        }

        /**
         * @description Gets a specific call arguments indexed by the parameters names
         *
         * @param callNumber The number of the call to get the arguments
         *
         * @return The arguments indexed by the parameters names
         */
        public Map<String, Object> getCallArguments(Integer callNumber) {
            return this.callArgumentsByParamName.get(callNumber);
        }

        /**
         * @description Indexes the arguments by the parameters names
         *
         * @param arguments The method arguments
         * @return The arguments indexed by name
         */
        private Map<String, Object> indexArgumentsByParamName(List<Object> arguments) {
            Map<String, Object> paramsByName = new Map<String, Object>();
            for(Integer i = 0; i < this.paramNames.size(); i++) {
                paramsByName.put(this.paramNames[i], arguments[i]);
            }
            return paramsByName;
        }

        /**
         * @description Asserts the mocked method execution statistics using the constraints
         *              created in the stubbing phase
         *
         * @param throwAnException When True, instead of use System.assert for the
         * assertion, it will throw a MockException if the assertion fails
         */
        public void assert(Boolean throwAnException) {
            if(this.minTimes == null || this.maxTimes == null) {
                return;
            }
            String message = getAssertionMessage();
            Boolean isValid = this.callTimes >= this.minTimes && this.callTimes <= this.maxTimes;
            if(throwAnException) {
                if(!isValid) {
                    throw new MockerException(message);
                }
            } else {
                System.assert(isValid, message);
            }
        }

        /**
         * @description Creates the assertion message according with the assertion type
         *
         * @return The assertion message
         */
        private String getAssertionMessage() {
            String message;
            if(this.minTimes == this.maxTimes) {
                switch on this.minTimes {
                    when 0 {
                        message = 'should never be called';
                    }
                    when 1 {
                        message = 'should be called once';
                    }
                    when else {
                        message = 'should be called ' + this.minTimes + ' times';
                    }
                }
            } else {
                message = 'should be called between ' + this.minTimes + ' and ' + this.maxTimes + ' times';
            }
            return 'Method ' + this.getMethodSignature() + ' ' + message;
        }

        /**
         * @description Gets the method signature
         *
         * @return The method signature
         */
        private String getMethodSignature() {
            List<String> params = new List<String>();
            for(Integer i = 0; i < this.paramTypes.size(); i++) {
                params.add(String.valueOf(this.paramTypes[i]));
            }
            return methodName + '(' + String.join(params, ', ')  + ')';
        }
    }
}
