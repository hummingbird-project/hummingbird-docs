# ``/Jobs/JobDefinition``

Groups job parameters and process in one type.

```swift
struct SendEmailJobParameters: JobParameters {
    static let jobID = "SendEmail"
    let to: String
    let subject: String
    let body: String
}

let job = JobDefinition(parameters: SendEmailJobParameters.self) { parameters, context in
    try await myEmailService.sendEmail(to: parameters.to, subject: parameters.subject, body: parameters.body)
}

jobQueue.registerJob(job)
```