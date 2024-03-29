#include "_debug.h"
#include "worker.h"
#include "application.h"

#include <QDateTime>
#include <QMimeDatabase>
#include <QThread>
#include <KFileMetaData/ExtractorCollection>
#include <KFileMetaData/SimpleExtractionResult>

Worker* Worker::sm_worker = 0;

Worker* Worker::instance()
{
    if (!sm_worker) {
        sm_worker = new Worker();
    }
    return sm_worker;
}

void Worker::getVideoDuration(int index, const QString &path)
{
    QMimeDatabase db;
    QMimeType type = db.mimeTypeForFile(path);
    KFileMetaData::ExtractorCollection exCol;
    QList<KFileMetaData::Extractor*> extractors = exCol.fetchExtractors(type.name());
    KFileMetaData::SimpleExtractionResult result(path, type.name(),
                                                 KFileMetaData::ExtractionResult::ExtractMetaData);
    KFileMetaData::Extractor* ex = extractors.first();
    ex->extract(&result);
    auto properties = result.properties();
    int duration = properties[KFileMetaData::Property::Duration].toInt();

    emit videoDuration(index, Application::formatTime(duration));
}

