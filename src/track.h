#ifndef TRACK_H
#define TRACK_H

#include <QObject>

class Track : public QObject
{
    Q_OBJECT
public:
    explicit Track(QObject *parent = nullptr);

    QString lang() const;
    void setLang(const QString &lang);

    QString title() const;
    void setTitle(const QString &title);

    QString codec() const;
    void setCodec(const QString &codec);

    qlonglong id() const;
    void setId(const qlonglong &id);

    qlonglong ffIndex() const;
    void setFfIndex(const qlonglong &ffIndex);

    qlonglong srcId() const;
    void setSrcId(const qlonglong &srcId);

    bool dependent() const;
    void setDependent(bool dependent);

    bool external() const;
    void setExternal(bool external);

    bool selected() const;
    void setSelected(bool selected);

    bool forced() const;
    void setForced(bool forced);

    bool defaut() const;
    void setDefaut(bool defaut);

    QString type() const;
    void setType(const QString &type);

signals:

public slots:

private:
    QString m_lang;
    QString m_title;
    QString m_codec;
    QString m_type;
    qlonglong m_id;
    qlonglong m_ffIndex;
    qlonglong m_srcId;
    bool m_defaut;
    bool m_dependent;
    bool m_external;
    bool m_selected;
    bool m_forced;
};

#endif // TRACK_H
