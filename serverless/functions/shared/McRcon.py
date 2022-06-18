import boto3
import time 

class McRcon:
    def __init__(self, password) -> None:
        self.password = password
        self.client = boto3.client('ssm')

    def runCommand(self, instance_id, cmd):
        response = self.client.send_command(
            InstanceIds=[instance_id],
            DocumentName='AWS-RunShellScript',
            Parameters={
                'commands': [
                    f"mcrcon -H 127.0.0.1 -p {self.password} {cmd}"
                ]
            }
        )
        command_id = response['Command']['CommandId']
        tries = 0
        output = ''
        while tries < 10:
            tries = tries + 1
            try:
                time.sleep(0.5)  # some delay always required...
                result = self.client.get_command_invocation(
                    CommandId=command_id,
                    InstanceId=instance_id,
                )
                if result['Status'] == 'InProgress':
                    continue
                output = result['StandardOutputContent']
                break
            except self.client.exceptions.InvocationDoesNotExist:
                continue

        return output 