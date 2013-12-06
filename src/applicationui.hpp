/*
 * Copyright (c) 2011-2013 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QObject>
#include <bb/data/SqlDataAccess>

namespace bb {
namespace cascades {
class Application;
class LocaleHandler;
}
}

class QTranslator;

/*!
 * @brief Application object
 *
 *
 */

class ApplicationUI: public QObject {
	Q_OBJECT
public:
	ApplicationUI(bb::cascades::Application *app);

	Q_INVOKABLE
	void compareJSONandSQLspeakers();

	Q_INVOKABLE
	void convertXMLtoJSONspeaker();

	Q_INVOKABLE
	void convertXMLtoJSONAddresses();

	Q_INVOKABLE
	void convertJSONtoXMLAddresses();

	Q_INVOKABLE
	void compareJSONandXMLaddresses();

	Q_INVOKABLE
	void compareJSONandXMLspeaker();

	virtual ~ApplicationUI() {
	}
signals:
	void speedTestAddresses(int max, int readJson, int writeJson, int readXml, int writeXml, int readSQL, int writeSQL);
	void speedTestSpeakerSQL(int max, int readJson, int writeJson, int readSQL, int writeSQL);
	void speedTestSpeaker(int max, int readXml, int readJson, int readConvertedJson);
	void conversionDone();

private slots:
	void onSystemLanguageChanged();

private:
	QTranslator* m_pTranslator;
	bb::cascades::LocaleHandler* m_pLocaleHandler;

	void convertSpeaker(QVariant& data);

	// S Q L
	bool mDatabaseAvailable;
	bool initDatabase();
	bb::data::SqlDataAccess* mSQLda;
	void firstInitSqliteAddresses();
	void firstInitSqliteSpeakers();
	QList<int> readWriteSQLaddresses();
	QList<int> readWriteSQLspeakers();
	QString createTableCommandForAddresses(const QVariantMap& addressMap);
	QString createTableCommandForSpeakers(const QVariantMap& speakerMap);
	QString createParameterizedInsertCommand(const QVariantMap& addressMap,
			const QString& tableName);
	void createAndInsertAddressesFromList(const QVariantList& allAddresses);
	void createAndInsertSpeakersFromList(const QVariantList& allSpeakers);
};

#endif /* ApplicationUI_HPP_ */
