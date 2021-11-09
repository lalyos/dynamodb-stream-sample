## DunamoDB Stream and Lambda

based on: [official docs](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.Lambda.Tutorial.html)

![image](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/images/StreamsAndTriggers.png)

## Usage

Create iinfra
```
make step1-create-table
make step2a-create-role
make step2b-put-role-policy
make step3a-create-topic
make step3b-subscribe
# confirm email
make step4-create-function
make step5-create-trigger
```

In case you have to fix lambda code
```
make update-function-code
```

## Testing lambda with local payload
```
make test-payload
```

## Final step
Insert some new records
```
make put-item name="Gipsz Jakab"
```