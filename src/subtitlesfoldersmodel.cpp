#include "_debug.h"
#include "subtitlesfoldersmodel.h"

#include <KConfig>
#include <KConfigDialog>
#include <KConfigGroup>


SubtitlesFoldersModel::SubtitlesFoldersModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_config = KSharedConfig::openConfig("georgefb/haruna.conf");
    m_list = m_config->group("General").readPathEntry("SubtitlesFolders", QStringList());
}

int SubtitlesFoldersModel::rowCount(const QModelIndex &parent) const
{
    // ToDo: ???
    if (parent.isValid()) {
        return 0;
    }
    return m_list.size();
}

QVariant SubtitlesFoldersModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    QString path = m_list[index.row()];

    switch (role) {
    case Qt::DisplayRole:
        return QVariant(path);
    }

    return QVariant();
}

void SubtitlesFoldersModel::updateFolder(QString folder, int row)
{
    m_list.replace(row, folder);
    QStringList newList = m_list;
    newList.removeAll(QString(""));
    m_config->group("General").writePathEntry("SubtitlesFolders", newList);
    m_config->sync();
}

void SubtitlesFoldersModel::deleteFolder(int row)
{
    emit beginRemoveRows(QModelIndex(), row, row);
    m_list.removeAt(row);
    emit endRemoveRows();
    m_config->group("General").writePathEntry("SubtitlesFolders", m_list);
    m_config->sync();
}

void SubtitlesFoldersModel::addFolder()
{
    emit beginInsertRows(QModelIndex(), m_list.size(), m_list.size());
    m_list.append(QStringLiteral());
    emit endInsertRows();
}
