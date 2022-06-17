class Response():
  def __init__(self, status_code, body) -> None:
    self.status_code = status_code
    self.body = body
  
  def json(self):
    return {
        "statusCode": self.status_code,
        "body": self.body
    }

class OK200(Response):
    def __init__(self, body) -> None:
       super().__init__(200, body)


class BadRequest400(Response):
    def __init__(self, body) -> None:
       super().__init__(400, body)