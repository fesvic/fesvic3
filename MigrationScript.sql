IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
CREATE TABLE [Admins] (
    [Id] int NOT NULL IDENTITY,
    [Email] nvarchar(max) NOT NULL,
    [Password] nvarchar(max) NOT NULL,
    CONSTRAINT [PK_Admins] PRIMARY KEY ([Id])
);

CREATE TABLE [Answers] (
    [Id] int NOT NULL IDENTITY,
    [StudentId] int NOT NULL,
    [SubjectId] int NOT NULL,
    [QuestionId] int NOT NULL,
    [SelectedOption] nvarchar(max) NULL,
    CONSTRAINT [PK_Answers] PRIMARY KEY ([Id])
);

CREATE TABLE [Students] (
    [Id] int NOT NULL IDENTITY,
    [Name] nvarchar(max) NOT NULL,
    [ExamNumber] nvarchar(max) NOT NULL,
    [ClassName] nvarchar(max) NULL,
    [PhotoPath] nvarchar(max) NULL,
    [HasSubmitted] bit NOT NULL,
    CONSTRAINT [PK_Students] PRIMARY KEY ([Id])
);

CREATE TABLE [Subjects] (
    [Id] int NOT NULL IDENTITY,
    [Name] nvarchar(max) NOT NULL,
    [TimeLimitInMinutes] int NOT NULL,
    CONSTRAINT [PK_Subjects] PRIMARY KEY ([Id])
);

CREATE TABLE [Questions] (
    [Id] int NOT NULL IDENTITY,
    [Text] nvarchar(max) NULL,
    [SubjectId] int NOT NULL,
    [OptionA] nvarchar(max) NULL,
    [OptionB] nvarchar(max) NULL,
    [OptionC] nvarchar(max) NULL,
    [OptionD] nvarchar(max) NULL,
    [CorrectOption] nvarchar(max) NULL,
    CONSTRAINT [PK_Questions] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Questions_Subjects_SubjectId] FOREIGN KEY ([SubjectId]) REFERENCES [Subjects] ([Id]) ON DELETE CASCADE
);

CREATE TABLE [QuizResults] (
    [Id] int NOT NULL IDENTITY,
    [StudentId] int NOT NULL,
    [SubjectId] int NOT NULL,
    [Score] int NOT NULL,
    [TakenAt] datetime2 NOT NULL,
    CONSTRAINT [PK_QuizResults] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_QuizResults_Students_StudentId] FOREIGN KEY ([StudentId]) REFERENCES [Students] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_QuizResults_Subjects_SubjectId] FOREIGN KEY ([SubjectId]) REFERENCES [Subjects] ([Id]) ON DELETE CASCADE
);

CREATE INDEX [IX_Questions_SubjectId] ON [Questions] ([SubjectId]);

CREATE INDEX [IX_QuizResults_StudentId] ON [QuizResults] ([StudentId]);

CREATE INDEX [IX_QuizResults_SubjectId] ON [QuizResults] ([SubjectId]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250602234925_InitialCreate', N'9.0.5');

ALTER TABLE [Questions] ADD [IsTheory] bit NOT NULL DEFAULT CAST(0 AS bit);

ALTER TABLE [Answers] ADD [SubmittedAt] nvarchar(max) NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250604192739_AddQuestionGen', N'9.0.5');

ALTER TABLE [Subjects] ADD [DifficultyLevel] nvarchar(max) NULL;

ALTER TABLE [Subjects] ADD [IconUrl] nvarchar(max) NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250605004535_AddSubjectIconsAndTiming', N'9.0.5');

EXEC sp_rename N'[Subjects].[TimeLimitInMinutes]', N'TimeLimitMinutes', 'COLUMN';

ALTER TABLE [Subjects] ADD [IsTaken] nvarchar(max) NULL;

ALTER TABLE [Subjects] ADD [Status] bit NOT NULL DEFAULT CAST(0 AS bit);

ALTER TABLE [Questions] ADD [Options] nvarchar(max) NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250605065327_FixQuestionSubjectRelationship', N'9.0.5');

DECLARE @var sysname;
SELECT @var = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Subjects]') AND [c].[name] = N'Status');
IF @var IS NOT NULL EXEC(N'ALTER TABLE [Subjects] DROP CONSTRAINT [' + @var + '];');
ALTER TABLE [Subjects] ALTER COLUMN [Status] nvarchar(max) NULL;

DECLARE @var1 sysname;
SELECT @var1 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Subjects]') AND [c].[name] = N'IsTaken');
IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [Subjects] DROP CONSTRAINT [' + @var1 + '];');
UPDATE [Subjects] SET [IsTaken] = CAST(0 AS bit) WHERE [IsTaken] IS NULL;
ALTER TABLE [Subjects] ALTER COLUMN [IsTaken] bit NOT NULL;
ALTER TABLE [Subjects] ADD DEFAULT CAST(0 AS bit) FOR [IsTaken];

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250605080932_PendingChanges', N'9.0.5');

CREATE TABLE [QuizAnswers] (
    [Id] int NOT NULL IDENTITY,
    [QuizResultId] int NOT NULL,
    [QuestionId] int NOT NULL,
    [SelectedOption] nvarchar(max) NULL,
    [IsCorrect] bit NOT NULL,
    CONSTRAINT [PK_QuizAnswers] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_QuizAnswers_Questions_QuestionId] FOREIGN KEY ([QuestionId]) REFERENCES [Questions] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_QuizAnswers_QuizResults_QuizResultId] FOREIGN KEY ([QuizResultId]) REFERENCES [QuizResults] ([Id]) ON DELETE CASCADE
);

CREATE INDEX [IX_QuizAnswers_QuestionId] ON [QuizAnswers] ([QuestionId]);

CREATE INDEX [IX_QuizAnswers_QuizResultId] ON [QuizAnswers] ([QuizResultId]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250605163010_FixSubjectIdShadowProperty', N'9.0.5');

EXEC sp_rename N'[Questions].[Options]', N'Answer', 'COLUMN';

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250606102232_FixedSubjectRelation', N'9.0.5');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250606131241_AddSubjectQuestion', N'9.0.5');

EXEC sp_rename N'[Subjects].[TimeLimitMinutes]', N'TimeLimit', 'COLUMN';

DECLARE @var2 sysname;
SELECT @var2 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Subjects]') AND [c].[name] = N'Name');
IF @var2 IS NOT NULL EXEC(N'ALTER TABLE [Subjects] DROP CONSTRAINT [' + @var2 + '];');
ALTER TABLE [Subjects] ALTER COLUMN [Name] nvarchar(max) NULL;

ALTER TABLE [Subjects] ADD [Title] nvarchar(max) NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250606173032_UpdateSubjectAndQuestion', N'9.0.5');

DECLARE @var3 sysname;
SELECT @var3 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Subjects]') AND [c].[name] = N'TimeLimit');
IF @var3 IS NOT NULL EXEC(N'ALTER TABLE [Subjects] DROP CONSTRAINT [' + @var3 + '];');
ALTER TABLE [Subjects] DROP COLUMN [TimeLimit];

ALTER TABLE [Answers] ADD [IsCorrect] bit NOT NULL DEFAULT CAST(0 AS bit);

ALTER TABLE [Answers] ADD [QuizResultId] int NOT NULL DEFAULT 0;

CREATE INDEX [IX_Answers_QuestionId] ON [Answers] ([QuestionId]);

CREATE INDEX [IX_Answers_QuizResultId] ON [Answers] ([QuizResultId]);

ALTER TABLE [Answers] ADD CONSTRAINT [FK_Answers_Questions_QuestionId] FOREIGN KEY ([QuestionId]) REFERENCES [Questions] ([Id]) ON DELETE CASCADE;

ALTER TABLE [Answers] ADD CONSTRAINT [FK_Answers_QuizResults_QuizResultId] FOREIGN KEY ([QuizResultId]) REFERENCES [QuizResults] ([Id]) ON DELETE NO ACTION;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250607091408_AddQuizResultToAnswers', N'9.0.5');

ALTER TABLE [Questions] DROP CONSTRAINT [FK_Questions_Subjects_SubjectId1];

DROP INDEX [IX_Questions_SubjectId1] ON [Questions];

DECLARE @var4 sysname;
SELECT @var4 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Questions]') AND [c].[name] = N'SubjectId1');
IF @var4 IS NOT NULL EXEC(N'ALTER TABLE [Questions] DROP CONSTRAINT [' + @var4 + '];');
ALTER TABLE [Questions] DROP COLUMN [SubjectId1];

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250607112507_AddNewFieldsToStudent', N'9.0.5');

ALTER TABLE [Answers] DROP CONSTRAINT [FK_Answers_QuizResults_QuizResultId];

ALTER TABLE [Answers] ADD CONSTRAINT [FK_Answers_QuizResults_QuizResultId] FOREIGN KEY ([QuizResultId]) REFERENCES [QuizResults] ([Id]) ON DELETE CASCADE;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250607123546_EnableCascadeDeleteForQuizResultAnswers', N'9.0.5');

ALTER TABLE [Questions] DROP CONSTRAINT [FK_Questions_Subjects_SubjectId];

ALTER TABLE [Questions] ADD CONSTRAINT [FK_Questions_Subjects_SubjectId] FOREIGN KEY ([SubjectId]) REFERENCES [Subjects] ([Id]) ON DELETE NO ACTION;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250607151311_UpdateCascadeFix', N'9.0.5');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250607174849_FixQuestionIdentity', N'9.0.5');

ALTER TABLE [QuizResults] DROP CONSTRAINT [FK_QuizResults_Students_StudentId];

ALTER TABLE [QuizResults] DROP CONSTRAINT [FK_QuizResults_Subjects_SubjectId];

ALTER TABLE [QuizResults] ADD CONSTRAINT [FK_QuizResults_Students_StudentId] FOREIGN KEY ([StudentId]) REFERENCES [Students] ([Id]) ON DELETE NO ACTION;

ALTER TABLE [QuizResults] ADD CONSTRAINT [FK_QuizResults_Subjects_SubjectId] FOREIGN KEY ([SubjectId]) REFERENCES [Subjects] ([Id]) ON DELETE NO ACTION;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250608000352_FinalFix', N'9.0.5');

ALTER TABLE [Questions] ADD [Mark] float NOT NULL DEFAULT 0.0E0;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250608005521_AddMarkToQuestion', N'9.0.5');

ALTER TABLE [Questions] ADD [ImageUrl] nvarchar(max) NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250608090321_AddImageUrlToQuestion', N'9.0.5');

DECLARE @var5 sysname;
SELECT @var5 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[QuizResults]') AND [c].[name] = N'Score');
IF @var5 IS NOT NULL EXEC(N'ALTER TABLE [QuizResults] DROP CONSTRAINT [' + @var5 + '];');
ALTER TABLE [QuizResults] ALTER COLUMN [Score] float NOT NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250608131614_AddToQuestion', N'9.0.5');

ALTER TABLE [QuizResults] ADD [TotalMarks] float NOT NULL DEFAULT 0.0E0;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250608170254_TotalMarksandScore', N'9.0.5');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250608194457_QuizStartViewModel', N'9.0.5');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250608195045_AddAnswer', N'9.0.5');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250608201259_AddcscoreMark', N'9.0.5');

ALTER TABLE [Answers] ADD [CorrectOption] nvarchar(max) NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250608204226_AddCorrectOption', N'9.0.5');

ALTER TABLE [QuizAnswers] ADD [CorrectOption] nvarchar(max) NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250608204823_AddCorrectOptionQuizAnswer', N'9.0.5');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250608214013_QuizHistoryViewModel', N'9.0.5');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250609015715_StudentResultViewModel', N'9.0.5');

ALTER TABLE [Questions] ADD [Difficulty] nvarchar(max) NULL;

ALTER TABLE [Questions] ADD [Topic] nvarchar(max) NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250609143808_Quizijustdone', N'9.0.5');

CREATE TABLE [StudentSubjects] (
    [StudentsId] int NOT NULL,
    [SubjectsId] int NOT NULL,
    CONSTRAINT [PK_StudentSubjects] PRIMARY KEY ([StudentsId], [SubjectsId]),
    CONSTRAINT [FK_StudentSubjects_Students_StudentsId] FOREIGN KEY ([StudentsId]) REFERENCES [Students] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_StudentSubjects_Subjects_SubjectsId] FOREIGN KEY ([SubjectsId]) REFERENCES [Subjects] ([Id]) ON DELETE CASCADE
);

CREATE INDEX [IX_StudentSubjects_SubjectsId] ON [StudentSubjects] ([SubjectsId]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250609204152_StudentSubjectrel', N'9.0.5');

ALTER TABLE [StudentSubjects] DROP CONSTRAINT [FK_StudentSubjects_Students_StudentsId];

ALTER TABLE [StudentSubjects] DROP CONSTRAINT [FK_StudentSubjects_Subjects_SubjectsId];

DECLARE @var6 sysname;
SELECT @var6 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Answers]') AND [c].[name] = N'IsCorrect');
IF @var6 IS NOT NULL EXEC(N'ALTER TABLE [Answers] DROP CONSTRAINT [' + @var6 + '];');
ALTER TABLE [Answers] DROP COLUMN [IsCorrect];

EXEC sp_rename N'[StudentSubjects].[SubjectsId]', N'SubjectId', 'COLUMN';

EXEC sp_rename N'[StudentSubjects].[StudentsId]', N'StudentId', 'COLUMN';

EXEC sp_rename N'[StudentSubjects].[IX_StudentSubjects_SubjectsId]', N'IX_StudentSubjects_SubjectId', 'INDEX';

ALTER TABLE [StudentSubjects] ADD [QuestionId] int NULL;

DECLARE @var7 sysname;
SELECT @var7 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Students]') AND [c].[name] = N'Name');
IF @var7 IS NOT NULL EXEC(N'ALTER TABLE [Students] DROP CONSTRAINT [' + @var7 + '];');
ALTER TABLE [Students] ALTER COLUMN [Name] nvarchar(max) NULL;

DECLARE @var8 sysname;
SELECT @var8 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Students]') AND [c].[name] = N'ExamNumber');
IF @var8 IS NOT NULL EXEC(N'ALTER TABLE [Students] DROP CONSTRAINT [' + @var8 + '];');
ALTER TABLE [Students] ALTER COLUMN [ExamNumber] nvarchar(max) NULL;

ALTER TABLE [QuizResults] ADD [ExamNumber] nvarchar(max) NULL;

ALTER TABLE [QuizResults] ADD [ScoreObtained] float NOT NULL DEFAULT 0.0E0;

ALTER TABLE [QuizResults] ADD [StudentName] nvarchar(max) NULL;

ALTER TABLE [Questions] ADD [CreatedAt] nvarchar(max) NULL;

ALTER TABLE [Questions] ADD [TakenAt] datetime2 NOT NULL DEFAULT '0001-01-01T00:00:00.0000000';

ALTER TABLE [Questions] ADD [UpdatedAt] datetime2 NOT NULL DEFAULT '0001-01-01T00:00:00.0000000';

CREATE INDEX [IX_StudentSubjects_QuestionId] ON [StudentSubjects] ([QuestionId]);

ALTER TABLE [StudentSubjects] ADD CONSTRAINT [FK_StudentSubjects_Questions_QuestionId] FOREIGN KEY ([QuestionId]) REFERENCES [Questions] ([Id]);

ALTER TABLE [StudentSubjects] ADD CONSTRAINT [FK_StudentSubjects_Students_StudentId] FOREIGN KEY ([StudentId]) REFERENCES [Students] ([Id]) ON DELETE CASCADE;

ALTER TABLE [StudentSubjects] ADD CONSTRAINT [FK_StudentSubjects_Subjects_SubjectId] FOREIGN KEY ([SubjectId]) REFERENCES [Subjects] ([Id]) ON DELETE CASCADE;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250612072446_UpdateModelChanges', N'9.0.5');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250612095504_FixedStudentSubjectMapping2222', N'9.0.5');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250612103923_Fixresul', N'9.0.5');

ALTER TABLE [QuizResults] ADD [Answers] nvarchar(max) NULL;

ALTER TABLE [QuizResults] ADD [IsCorrect] bit NOT NULL DEFAULT CAST(0 AS bit);

ALTER TABLE [QuizResults] ADD [Question] nvarchar(max) NULL;

ALTER TABLE [QuizResults] ADD [SelectedOption] nvarchar(max) NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250612202057_AddResultViewModelOrOtherChanges', N'9.0.5');

CREATE INDEX [IX_Answers_StudentId] ON [Answers] ([StudentId]);

ALTER TABLE [Answers] ADD CONSTRAINT [FK_Answers_Students_StudentId] FOREIGN KEY ([StudentId]) REFERENCES [Students] ([Id]) ON DELETE CASCADE;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250613033932_AddResultViallrsulst', N'9.0.5');

ALTER TABLE [QuizAnswers] DROP CONSTRAINT [FK_QuizAnswers_QuizResults_QuizResultId];

ALTER TABLE [QuizAnswers] ADD CONSTRAINT [FK_QuizAnswers_QuizResults_QuizResultId] FOREIGN KEY ([QuizResultId]) REFERENCES [QuizResults] ([Id]) ON DELETE NO ACTION;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250614005209_AddQuizAnswerRelations1werteytfuyf', N'9.0.5');

COMMIT;
GO

